import 'package:fgtracker/app/Data/Repositories/banner_Repo.dart';
import 'package:fgtracker/app/Model/paid_banner_models.dart';
import 'package:fgtracker/app/modules/banners/Views/create_banner_ad_screen.dart';
import 'package:fgtracker/app/modules/banners/Views/my_banners_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BannerPlansScreen extends StatefulWidget {
  final UserBannerAdModel? renewBanner;

  const BannerPlansScreen({super.key, this.renewBanner});

  @override
  State<BannerPlansScreen> createState() => _BannerPlansScreenState();
}

class _BannerPlansScreenState extends State<BannerPlansScreen> {
  bool _loading = true;
  String? _error;
  List<BannerPlanModel> _plans = [];

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
      final plans = await BannerRepo.getPlans();
      if (mounted) {
        setState(() {
          _plans = plans;
          _loading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    final isRenew = widget.renewBanner != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(isRenew ? 'Renew Banner Ad' : 'Banner Ad Plans'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!isRenew)
            TextButton.icon(
              onPressed: () => Get.to(() => const MyBannersScreen()),
              icon: const Icon(Icons.campaign_rounded, color: Colors.white),
              label: const Text(
                'My Ads',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
        ],
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
              : _plans.isEmpty
                  ? const Center(
                      child: Text('No banner plans available right now.'),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPlans,
                      child: ListView.separated(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _plans.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          final p = plan.pricing;
                          return Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
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
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E1B4B),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      child: Text(
                                        '${plan.durationDays} Days',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF4F46E5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (plan.description != null &&
                                    plan.description!.isNotEmpty) ...[
                                  SizedBox(height: 6.h),
                                  Text(
                                    plan.description!,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 10.h),
                                Text(
                                  plan.slotNumber != null
                                      ? 'Valid for Slide ${plan.slotNumber}'
                                      : 'Valid for any available Slide (1 – 7)',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF6366F1),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Divider(height: 20.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.formatAmount(p.totalAmount),
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        Text(
                                          p.gstPercent > 0
                                              ? 'Base ${p.formatAmount(p.baseAmount)} + ${p.gstPercent.toStringAsFixed(0)}% GST (${p.formatAmount(p.gstAmount)})'
                                              : 'Tax / GST: ${p.formatAmount(0)}',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF4F46E5),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                      ),
                                      onPressed: () {
                                        Get.to(
                                          () => CreateBannerAdScreen(
                                            plan: plan,
                                            renewBanner: widget.renewBanner,
                                          ),
                                        );
                                      },
                                      child: const Text('Select Slot'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
