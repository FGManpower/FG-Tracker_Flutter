import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fgtracker/app/Data/Repositories/banner_Repo.dart';
import 'package:fgtracker/app/Model/paid_banner_models.dart';
import 'package:fgtracker/app/modules/banners/Views/banner_plans_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MyBannersScreen extends StatefulWidget {
  const MyBannersScreen({super.key});

  @override
  State<MyBannersScreen> createState() => _MyBannersScreenState();
}

class _MyBannersScreenState extends State<MyBannersScreen> {
  final List<String> _filters = const [
    'all',
    'active',
    'pending',
    'rejected',
    'expired',
    'refunded',
  ];

  String _selectedFilter = 'all';
  bool _loading = true;
  List<UserBannerAdModel> _ads = [];

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  Future<void> _loadAds() async {
    setState(() => _loading = true);
    try {
      final list = await BannerRepo.getMyBanners(status: _selectedFilter);
      if (mounted) {
        setState(() {
          _ads = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        Fluttertoast.showToast(msg: 'Unable to load banners: $e');
      }
    }
  }

  Future<void> _confirmRefund(UserBannerAdModel ad) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Claim Refund?'),
        content: const Text(
          'This will issue a Razorpay refund for your rejected banner and release the booked slot.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Refund'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await BannerRepo.requestRefund(ad.id);
      Fluttertoast.showToast(msg: 'Refund initiated successfully');
      _loadAds();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Refund failed: $e');
    }
  }

  Future<void> _openResubmitSheet(UserBannerAdModel ad) async {
    final titleCtrl = TextEditingController(text: ad.title);
    final urlCtrl = TextEditingController(text: ad.targetUrl ?? '');
    File? newImage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 16.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit & Resubmit (Free)',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: urlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Target URL (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setModalState(() => newImage = File(picked.path));
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: Text(
                      newImage != null
                          ? 'New Image Selected'
                          : 'Choose New Image (Optional)',
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        try {
                          await BannerRepo.resubmitRejectedBanner(
                            bannerId: ad.id,
                            title: titleCtrl.text,
                            targetUrl: urlCtrl.text,
                            imageFile: newImage,
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          Fluttertoast.showToast(
                            msg: 'Resubmitted for Admin approval',
                          );
                          _loadAds();
                        } catch (e) {
                          Fluttertoast.showToast(msg: 'Resubmit failed: $e');
                        }
                      },
                      child: const Text('Submit for Approval'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending_review':
      case 'pending_payment':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('My Banner Ads'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        onPressed: () => Get.to(() => const BannerPlansScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Book Ad'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final f = _filters[index];
                final selected = _selectedFilter == f;
                return ChoiceChip(
                  label: Text(f.toUpperCase()),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedFilter = f);
                    _loadAds();
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _ads.isEmpty
                    ? const Center(child: Text('No banner ads found.'))
                    : RefreshIndicator(
                        onRefresh: _loadAds,
                        child: ListView.separated(
                          padding: EdgeInsets.all(14.w),
                          itemCount: _ads.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final ad = _ads[index];
                            return Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (ad.resolvedImageUrl.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.r),
                                      child: CachedNetworkImage(
                                        imageUrl: ad.resolvedImageUrl,
                                        height: 120.h,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ad.title,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(ad.status)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          ad.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: _statusColor(ad.status),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Slide ${ad.slotNumber} • ${ad.planName ?? 'Plan'} • Views: ${ad.impressionsCount} | Clicks: ${ad.clicksCount}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  if (ad.startsAt != null &&
                                      ad.expiresAt != null)
                                    Text(
                                      '${ad.startsAt!.split('T').first} → ${ad.expiresAt!.split('T').first}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  if (ad.status == 'rejected' &&
                                      ad.rejectionReason != null) ...[
                                    SizedBox(height: 6.h),
                                    Text(
                                      'Reason: ${ad.rejectionReason}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                _openResubmitSheet(ad),
                                            child: const Text(
                                              'Edit & Resubmit (Free)',
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () => _confirmRefund(ad),
                                            child: const Text('Claim Refund'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (ad.status == 'expired' ||
                                      ad.status == 'refunded') ...[
                                    SizedBox(height: 8.h),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF4F46E5),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () => Get.to(
                                          () => BannerPlansScreen(
                                            renewBanner: ad,
                                          ),
                                        ),
                                        child: const Text('Renew Ad'),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
