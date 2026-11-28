import 'package:fgtracker/app/Data/Repositories/attendance_subscription_repo.dart';
import 'package:fgtracker/app/modules/Attendance/models/attendance_subscription_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttendancePlansScreen extends StatefulWidget {
  const AttendancePlansScreen({super.key});

  @override
  State<AttendancePlansScreen> createState() => _AttendancePlansScreenState();
}

class _AttendancePlansScreenState extends State<AttendancePlansScreen> {
  bool _loading = true;
  String? _error;
  String _currency = 'INR';
  List<AttendancePlanModel> _plans = [];
  int _previewMembers = 10;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await AttendanceSubscriptionRepo.getPlans();
      if (!mounted) return;
      setState(() {
        _currency = res.currency;
        _plans = res.plans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInr = _currency.toUpperCase() == 'INR';
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Attendance Plans & Pricing'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        SizedBox(height: 12.h),
                        ElevatedButton(
                          onPressed: _loadPlans,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPlans,
                  child: ListView(
                    padding: EdgeInsets.all(16.w),
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Group Chat Attendance Subscription',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Admin pays per member seat. Members mark attendance for free. Includes 7-day free trial for new admins.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Estimate for members:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _previewMembers > 1
                                  ? () => setState(() => _previewMembers--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$_previewMembers',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _previewMembers++),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      if (_plans.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                                'No Attendance packages configured right now.'),
                          ),
                        )
                      else
                        ..._plans.map((plan) {
                          final subtotal =
                              plan.pricePerMember * _previewMembers;
                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        plan.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        '${plan.billingInterval.toUpperCase()} (${plan.durationMonths}m)',
                                        style: TextStyle(
                                          color: const Color(0xFF4F46E5),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (plan.description != null &&
                                    plan.description!.isNotEmpty) ...[
                                  SizedBox(height: 4.h),
                                  Text(
                                    plan.description!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 10.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${formatAttendanceCurrency(plan.pricePerMember, plan.currency)} / member',
                                      style: TextStyle(
                                        color: const Color(0xFF4F46E5),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    Text(
                                      'Est. $_previewMembers seats: ${formatAttendanceCurrency(subtotal, plan.currency)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  'Seats: ${plan.minMembers}–${plan.maxMembers?.toString() ?? 'Unlimited'} • ${isInr ? '+18% GST' : '0% Export GST'} • Coupons supported',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}
