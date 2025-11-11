Widget groupListUi({
  List<GroupData>? groupData,
  bool isLoading = false,
}) {
  return MyCustomPullToRefresh(
    onTapCallback: () {
      groupController.groupDataLoading.value = true;
    },
    onTap2Callback: () {
      groupController.getGroupData();
    },
    Indicatorekey: GlobalKey<LiquidPullToRefreshState>(),
    child: Skeletonizer(
      enabled: isLoading,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: groupData?.length ?? 8,
          separatorBuilder: (context, index) => SizedBox(width: 12.w),
          itemBuilder: (context, index) {
            final data = groupData?[index];
            final bool isActive = data?.isActive ?? false;
            final bool isCreator = data?.isCreator ?? false;

            return GestureDetector(
              onTap: () {
                if (isActive) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberscreenScreen(
                        groupId: data!.id.toString(),
                        isCreator: data.isCreator!,
                        isActive: data.isActive!,
                        groupName: data.groupName!,
                      ),
                    ),
                  ).then((value) {
                    if (value == true) {
                      groupController.getGroupData();
                    }
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 190.w,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xffE9E5FF)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xff5045B9)
                        : Colors.grey.shade300,
                    width: 1.2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          ? const Color(0xff5045B9).withOpacity(0.12)
                          : Colors.black12.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Group Name
                      reausabletext(
                        data?.groupName ?? AppText.unnamedTrip,
                        fontsize: 13,
                        color: Colors.black87,
                        fontfamily: FontFamily.interSemiBold,
                        maxline: 2,
                      ),
                      SizedBox(height: 8.h),

                      // Team Code + Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          reausabletext(
                            "Team Code",
                            fontsize: 10,
                            color: Colors.black87,
                            fontfamily: FontFamily.interRegular,
                          ),
                          CupertinoSwitch(
                            value: isActive,
                            activeColor: const Color(0xff5045B9),
                            trackColor: Colors.black26,
                            onChanged: (value) {
                              if (isCreator) {
                                groupController.updateGroup(
                                  groupController,
                                  groupId: data!.id.toString(),
                                  groupStatus: value.toString(),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // Group Code + Copy
                      Row(
                        children: [
                          reausabletext(
                            data?.groupCode ?? "",
                            fontfamily: FontFamily.interSemiBold,
                            fontsize: 12,
                            color: const Color(0xff5045B9),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: data?.groupCode ?? ""),
                              );
                              Utils().fluttertoast("Group code copied!");
                            },
                            child: Icon(Icons.copy,
                                size: 14.sp, color: const Color(0xff5045B9)),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),

                      // Show QR Code + Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isActive) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QrCodeScreen(
                                      groupCode: data?.groupCode ?? "",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: reausabletext(
                              "Show QR Code",
                              fontsize: 11,
                              color: const Color(0xff5045B9),
                              fontfamily: FontFamily.interMedium,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (isActive) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QrCodeScreen(
                                      groupCode: data?.groupCode ?? "",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xff5045B9),
                                  width: 1.4.w,
                                ),
                              ),
                              padding: EdgeInsets.all(6.r),
                              child: reausableIcon(
                                icon: FontAwesomeIcons.qrcode,
                                size: 16,
                                color: const Color(0xff5045B9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
