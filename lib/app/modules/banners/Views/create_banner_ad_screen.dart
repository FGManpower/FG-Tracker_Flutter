import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Data/Repositories/banner_Repo.dart';
import 'package:fgtracker/app/Model/paid_banner_models.dart';
import 'package:fgtracker/app/modules/banners/Views/my_banners_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CreateBannerAdScreen extends StatefulWidget {
  final BannerPlanModel plan;
  final UserBannerAdModel? renewBanner;

  const CreateBannerAdScreen({
    super.key,
    required this.plan,
    this.renewBanner,
  });

  @override
  State<CreateBannerAdScreen> createState() => _CreateBannerAdScreenState();
}

class _CreateBannerAdScreenState extends State<CreateBannerAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _ctaCtrl = TextEditingController();
  final _picker = ImagePicker();

  late Razorpay _razorpay;

  DateTime _startDate = DateTime.now();
  bool _loadingSlots = true;
  SlotAvailabilityResponse? _availability;
  int? _selectedSlot;
  File? _pickedImage;
  bool _isSubmitting = false;

  bool get _isRenew => widget.renewBanner != null;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);

    if (_isRenew) {
      _titleCtrl.text = widget.renewBanner!.title;
      _descCtrl.text = widget.renewBanner!.description ?? '';
      _urlCtrl.text = widget.renewBanner!.targetUrl ?? '';
      _ctaCtrl.text = widget.renewBanner!.ctaText ?? '';
    }
    _fetchSlots();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
    _ctaCtrl.dispose();
    super.dispose();
  }

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_startDate);

  Future<void> _fetchSlots() async {
    setState(() {
      _loadingSlots = true;
      _selectedSlot = null;
    });
    try {
      final resp = await BannerRepo.getSlotAvailability(
        planId: widget.plan.id,
        startDate: _formattedDate,
      );
      if (mounted) {
        setState(() {
          _availability = resp;
          final firstFree = resp.slots.where((s) => s.available).toList();
          if (firstFree.isNotEmpty) {
            _selectedSlot = firstFree.first.slotNumber;
          }
          _loadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingSlots = false);
        Fluttertoast.showToast(msg: 'Failed to check slots: $e');
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
      await _fetchSlots();
    }
  }

  Future<void> _pickAndCropImage() async {
    final xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1600,
    );
    if (xfile == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: xfile.path,
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Banner (2:1)',
          toolbarColor: const Color(0xFF4F46E5),
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Banner (2:1)',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped != null && mounted) {
      setState(() => _pickedImage = File(cropped.path));
    }
  }

  Future<void> _startCheckout() async {
    if (_selectedSlot == null) {
      Fluttertoast.showToast(msg: 'Please select an available slide slot');
      return;
    }
    if (!_isRenew && _pickedImage == null) {
      Fluttertoast.showToast(msg: 'Please upload a banner image');
      return;
    }
    if (!_isRenew && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final int bannerId = _isRenew
          ? await BannerRepo.renewBanner(
              bannerId: widget.renewBanner!.id,
              planId: widget.plan.id,
              slotNumber: _selectedSlot!,
              startDate: _formattedDate,
            )
          : await BannerRepo.createDraft(
              planId: widget.plan.id,
              slotNumber: _selectedSlot!,
              startDate: _formattedDate,
              title: _titleCtrl.text,
              description: _descCtrl.text,
              targetUrl: _urlCtrl.text,
              ctaText: _ctaCtrl.text,
              imageFile: _pickedImage!,
            );

      final order = await BannerRepo.createOrder(bannerId);

      final Map<String, dynamic> options = {
        'key': order.keyId,
        'amount': order.amountMinorUnits,
        'currency': order.currency,
        'name': 'FG Tracker Banner Ads',
        'description': '${widget.plan.name} - Slide ${order.slotNumber}',
        'order_id': order.razorpayOrderId,
        'prefill': {
          if (order.customerName != null) 'name': order.customerName,
          if (order.customerEmail != null) 'email': order.customerEmail,
          if (order.customerContact != null) 'contact': order.customerContact,
        },
      };

      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  Future<void> _onRazorpaySuccess(PaymentSuccessResponse response) async {
    try {
      await BannerRepo.verifyPayment(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
        Fluttertoast.showToast(
          msg: 'Payment successful! Banner submitted for Admin approval.',
        );
        Get.offAll(() => const MyBannersScreen());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Fluttertoast.showToast(msg: 'Verification failed: $e');
      }
    }
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _isSubmitting = false);
      Fluttertoast.showToast(
        msg: response.message ?? 'Payment cancelled or failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pricing = widget.plan.pricing;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(_isRenew ? 'Renew & Select Slot' : 'Book Banner Slot'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Date & Real-Time Slot Availability
              Text(
                '1. Select Start Date & Slide (Real-Time)',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: _pickDate,
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Start Date: $_formattedDate (${widget.plan.durationDays} days)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFF4F46E5)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              if (_loadingSlots)
                const Center(child: CircularProgressIndicator())
              else if (_availability != null)
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _availability!.slots.map((slot) {
                    final selected = _selectedSlot == slot.slotNumber;
                    return ChoiceChip(
                      selected: selected,
                      onSelected: slot.available
                          ? (_) => setState(() => _selectedSlot = slot.slotNumber)
                          : null,
                      selectedColor: const Color(0xFF4F46E5),
                      backgroundColor: slot.available
                          ? Colors.white
                          : Colors.grey.shade200,
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Slide ${slot.slotNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.white
                                  : (slot.available
                                      ? Colors.black87
                                      : Colors.grey),
                            ),
                          ),
                          Text(
                            slot.available
                                ? 'Available'
                                : 'Free ${slot.nextAvailableDate}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: selected
                                  ? Colors.white70
                                  : (slot.available
                                      ? Colors.green.shade700
                                      : Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(height: 20.h),

              // 2. Creative Image & Details
              Text(
                '2. Banner Creative & Details',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              if (_isRenew)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: CachedNetworkImage(
                    imageUrl: widget.renewBanner!.resolvedImageUrl,
                    height: 150.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                InkWell(
                  onTap: _pickAndCropImage,
                  child: Container(
                    height: 155.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _pickedImage != null
                        ? Image.file(_pickedImage!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: Color(0xFF4F46E5),
                              ),
                              SizedBox(height: 6.h),
                              const Text('Tap to Upload & Crop Banner (2:1)'),
                            ],
                          ),
                  ),
                ),
              if (!_isRenew) ...[
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Banner Title *',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Title is required'
                      : null,
                ),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: _urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tap URL / Website / WhatsApp Link (Optional)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.h),
                TextFormField(
                  controller: _ctaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Button Label (Optional, e.g. Learn More)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              SizedBox(height: 20.h),

              // 3. Payment Summary
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Plan Subtotal'),
                        Text(pricing.formatAmount(pricing.baseAmount)),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('GST (${pricing.gstPercent.toStringAsFixed(0)}%)'),
                        Text(pricing.formatAmount(pricing.gstAmount)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          pricing.formatAmount(pricing.totalAmount),
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _startCheckout,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Pay ${pricing.formatAmount(pricing.totalAmount)} & Submit',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
