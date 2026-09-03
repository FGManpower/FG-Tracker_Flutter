import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/modules/Messages/Controller/DocumentViewerController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../../Core/util/file_helper.dart';

class DocumentViewerScreen extends GetView<DocumentViewerController> {
  const DocumentViewerScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(
      DocumentViewerController(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              size: 20.sp,
              color: Colors.white,
            )),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.documentName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              controller.extension.toUpperCase(),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              controller.downloadFile();
            },
            icon: Icon(Icons.download, size: 20.sp, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share, size: 20.sp, color: Colors.white),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.isPdf) {
            return PDFView(
              filePath: controller.localFilePath.value,
            );
          }

          return Center(
            child: Container(
                margin: EdgeInsets.all(20.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(
                    16.r,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 15.h),
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: getFileColor(controller.documentUrl),
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: getFileColor(
                                controller.documentUrl,
                              ).withValues(alpha: .25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          getFileIcon(controller.documentUrl),
                          size: 65.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        controller.documentName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkBlue.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          controller.extension.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.darkBlue,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36.w,
                                  height: 36.w,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: .1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    "Document is available",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),
                            Text(
                              "Preview is not available for this file type. Open the document using your installed application.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13.sp,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.downloadFile,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: 14.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              child: Icon(
                                Icons.download_rounded,
                                size: 22.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: controller.openDocument,
                              icon: Icon(
                                Icons.open_in_new,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Open Document",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  vertical: 15.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                )),
          );
        },
      ),
    );
  }
}
