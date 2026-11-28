import 'package:fgtracker/app/Data/Repositories/attendance_subscription_repo.dart';
import 'package:fgtracker/app/modules/Attendance/models/attendance_subscription_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

Future<bool?> showAttendanceSubscriptionSheet({
  required BuildContext context,
  required int groupId,
  List<dynamic>? groupMembers,
  AttendanceSubscriptionStatusModel? initialStatus,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AttendanceSubscriptionSheet(
      groupId: groupId,
      groupMembers: groupMembers,
      initialStatus: initialStatus,
    ),
  );
}

class AttendanceSubscriptionSheet extends StatefulWidget {
  final int groupId;
  final List<dynamic>? groupMembers;
  final AttendanceSubscriptionStatusModel? initialStatus;

  const AttendanceSubscriptionSheet({
    super.key,
    required this.groupId,
    this.groupMembers,
    this.initialStatus,
  });

  @override
  State<AttendanceSubscriptionSheet> createState() =>
      _AttendanceSubscriptionSheetState();
}

class _AttendanceSubscriptionSheetState
    extends State<AttendanceSubscriptionSheet> {
  late Razorpay _razorpay;
  final TextEditingController _couponController = TextEditingController();

  bool _loading = true;
  bool _busy = false;
  String? _error;

  AttendanceSubscriptionStatusModel? _status;
  String _currency = 'INR';
  List<AttendancePlanModel> _plans = [];
  AttendancePlanModel? _selectedPlan;
  int _seats = 1;
  AttendanceOrderSummaryModel? _summary;
  AttendancePaymentOrderModel? _pendingOrder;

  // Seat management state
  late Set<int> _assignedIds;
  int _topupSeats = 1;

  @override
  void initState() {
    super.initState();
    _assignedIds =
        Set<int>.from(widget.initialStatus?.assignedMemberIds ?? const []);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onRazorpayError);
    _loadData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = widget.initialStatus ??
          await AttendanceSubscriptionRepo.getSubscriptionStatus(
              widget.groupId);
      final plansRes = await AttendanceSubscriptionRepo.getPlans();

      if (!mounted) return;
      setState(() {
        _status = status;
        _assignedIds = Set<int>.from(status.assignedMemberIds);
        _currency = plansRes.currency;
        _plans = plansRes.plans;
        if (_plans.isNotEmpty) {
          _selectedPlan = _plans.first;
          final minM = _selectedPlan!.minMembers;
          final maxM = _selectedPlan!.maxMembers;
          var initialSeats =
              status.groupMemberCount > 0 ? status.groupMemberCount : 1;
          if (initialSeats < minM) initialSeats = minM;
          if (maxM != null && initialSeats > maxM) initialSeats = maxM;
          _seats = initialSeats;
        }
        _loading = false;
      });
      if (_selectedPlan != null && !status.hasActiveSubscription) {
        await _refreshSummary();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _refreshSummary() async {
    if (_selectedPlan == null) return;
    try {
      final summary = await AttendanceSubscriptionRepo.getOrderSummary(
        planId: _selectedPlan!.id,
        purchasedSeats: _seats,
        couponCode: _couponController.text.trim(),
      );
      if (mounted) {
        setState(() => _summary = summary);
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  Future<void> _startFreeTrial() async {
    setState(() => _busy = true);
    try {
      await AttendanceSubscriptionRepo.startTrial(widget.groupId);
      if (mounted) {
        Fluttertoast.showToast(msg: '7-day free Attendance trial activated!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  Future<void> _startCheckout({bool isTopup = false}) async {
    setState(() => _busy = true);
    try {
      final order = isTopup
          ? await AttendanceSubscriptionRepo.topupSeats(
              groupId: widget.groupId,
              additionalSeats: _topupSeats,
              subscriptionId: _status?.subscriptionId,
            )
          : await AttendanceSubscriptionRepo.createOrder(
              groupId: widget.groupId,
              planId: _selectedPlan!.id,
              purchasedSeats: _seats,
              couponCode: _couponController.text.trim(),
            );

      _pendingOrder = order;
      final options = <String, dynamic>{
        'key': order.razorpayKeyId,
        'order_id': order.razorpayOrderId,
        'amount': order.amountMinor,
        'currency': order.currency,
        'name': 'FG MANPOWER LLP',
        'description': isTopup
            ? 'Attendance Seat Top-Up ($_topupSeats seats)'
            : '${_selectedPlan!.name} ($_seats members)',
        'timeout': 300,
        'prefill': {
          'name': order.customerName,
          'email': order.customerEmail,
          'contact': order.customerContact,
        },
        'theme': {'color': '#4F46E5'},
      };
      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  Future<void> _onRazorpaySuccess(PaymentSuccessResponse response) async {
    final pending = _pendingOrder;
    if (pending == null) return;
    try {
      await AttendanceSubscriptionRepo.verifyPayment(
        paymentId: pending.paymentId,
        razorpayOrderId: response.orderId ?? pending.razorpayOrderId,
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );
      if (mounted) {
        setState(() => _busy = false);
        Fluttertoast.showToast(msg: 'Attendance subscription activated!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        Fluttertoast.showToast(msg: 'Verification failed: $e');
      }
    }
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _busy = false);
      Fluttertoast.showToast(
        msg: response.message ?? 'Payment cancelled or failed',
      );
    }
  }

  Future<void> _saveSeatAssignments() async {
    setState(() => _busy = true);
    try {
      await AttendanceSubscriptionRepo.updateMemberSeats(
        groupId: widget.groupId,
        subscriptionId: _status?.subscriptionId,
        replaceUserIds: _assignedIds.toList(),
      );
      if (mounted) {
        setState(() => _busy = false);
        Fluttertoast.showToast(msg: 'Member seats updated!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        Fluttertoast.showToast(msg: e.toString());
      }
    }
  }

  int? _extractMemberId(dynamic m) {
    if (m is Map) {
      final raw = m['userId'] ?? m['UserId'] ?? m['id'];
      if (raw is num) return raw.toInt();
      if (raw != null) return int.tryParse(raw.toString());
    }
    return null;
  }

  String _extractMemberName(dynamic m) {
    if (m is Map) {
      return (m['Name'] ?? m['name'] ?? m['userName'] ?? 'Member').toString();
    }
    return 'Member';
  }

  @override
  Widget build(BuildContext context) {
    final isManageMode = _status?.hasActiveSubscription == true &&
        _status?.accessType == 'subscription';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 14.h, 12.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isManageMode
                          ? 'Manage Attendance Seats'
                          : 'Attendance Subscription',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _loading
                  ? Padding(
                      padding: EdgeInsets.all(40.h),
                      child: const CircularProgressIndicator(),
                    )
                  : _error != null
                      ? Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              SizedBox(height: 12.h),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(16.w),
                          child: isManageMode
                              ? _buildManageSeatsBody()
                              : _buildPurchaseBody(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageSeatsBody() {
    final maxSeats = _status?.purchasedSeats ?? 1;
    final members = widget.groupMembers ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _status?.planName ?? 'Active Plan',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
              ),
              Text(
                '${_assignedIds.length} / $maxSeats seats used',
                style: TextStyle(
                  color: const Color(0xFF4F46E5),
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'Assign Members',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        if (members.isEmpty)
          const Text('No group members list passed.')
        else
          ...members.map((m) {
            final uid = _extractMemberId(m);
            if (uid == null) return const SizedBox.shrink();
            final checked = _assignedIds.contains(uid);
            return CheckboxListTile(
              dense: true,
              value: checked,
              title: Text(_extractMemberName(m)),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    if (_assignedIds.length >= maxSeats) {
                      Fluttertoast.showToast(
                        msg: 'Seat limit ($maxSeats) reached. Top up seats below.',
                      );
                      return;
                    }
                    _assignedIds.add(uid);
                  } else {
                    _assignedIds.remove(uid);
                  }
                });
              },
            );
          }),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _busy ? null : _saveSeatAssignments,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            child: Text(_busy ? 'Saving...' : 'Save Seat Assignments'),
          ),
        ),
        SizedBox(height: 18.h),
        const Divider(),
        SizedBox(height: 10.h),
        Text(
          'Group Grown? Buy Additional Seats',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            IconButton(
              onPressed: _topupSeats > 1
                  ? () => setState(() => _topupSeats--)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '$_topupSeats seats',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            IconButton(
              onPressed: () => setState(() => _topupSeats++),
              icon: const Icon(Icons.add_circle_outline),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _busy ? null : () => _startCheckout(isTopup: true),
              child: const Text('Top Up'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPurchaseBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_status?.canStartTrial == true) ...[
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7-Day Free Trial Available',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Try Group Attendance free for 7 days on this group.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _busy ? null : _startFreeTrial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4F46E5),
                  ),
                  child: const Text('Start Trial'),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
        if (_plans.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No Attendance packages configured yet.'),
            ),
          )
        else ...[
          Text(
            'Select Package ($_currency)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          ..._plans.map((plan) {
            final isSelected = _selectedPlan?.id == plan.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlan = plan;
                  if (_seats < plan.minMembers) _seats = plan.minMembers;
                  if (plan.maxMembers != null && _seats > plan.maxMembers!) {
                    _seats = plan.maxMembers!;
                  }
                });
                _refreshSummary();
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4F46E5)
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? const Color(0xFFF5F3FF)
                      : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          '${plan.billingInterval.toUpperCase()} (${plan.durationMonths}m)',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${formatAttendanceCurrency(plan.pricePerMember, plan.currency)} / member',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4F46E5),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                'Member Seats:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              ),
              const Spacer(),
              IconButton(
                onPressed: (_selectedPlan != null &&
                        _seats > _selectedPlan!.minMembers)
                    ? () {
                        setState(() => _seats--);
                        _refreshSummary();
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$_seats',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed: (_selectedPlan != null &&
                        (_selectedPlan!.maxMembers == null ||
                            _seats < _selectedPlan!.maxMembers!))
                    ? () {
                        setState(() => _seats++);
                        _refreshSummary();
                      }
                    : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Coupon code (optional)',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              OutlinedButton(
                onPressed: _refreshSummary,
                child: const Text('Apply'),
              ),
            ],
          ),
          if (_summary != null) ...[
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _priceRow(
                    'Subtotal ($_seats × ${formatAttendanceCurrency(_summary!.pricing.pricePerMember, _summary!.currency)})',
                    formatAttendanceCurrency(
                        _summary!.pricing.subtotal, _summary!.currency),
                  ),
                  if (_summary!.pricing.discountAmount > 0)
                    _priceRow(
                      'Coupon Discount',
                      '-${formatAttendanceCurrency(_summary!.pricing.discountAmount, _summary!.currency)}',
                    ),
                  _priceRow(
                    '${_summary!.pricing.taxName} (${_summary!.pricing.gstPercent.toStringAsFixed(0)}%)',
                    formatAttendanceCurrency(
                        _summary!.pricing.gstAmount, _summary!.currency),
                  ),
                  const Divider(),
                  _priceRow(
                    'Total Payable',
                    formatAttendanceCurrency(
                        _summary!.pricing.finalAmount, _summary!.currency),
                    bold: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton(
                onPressed: _busy ? null : () => _startCheckout(isTopup: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  _busy
                      ? 'Processing...'
                      : 'Pay ${formatAttendanceCurrency(_summary!.pricing.finalAmount, _summary!.currency)} & Activate',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
