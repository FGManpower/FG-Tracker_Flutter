


import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:image_picker/image_picker.dart';

class ModalImage {
  final picker = ImagePicker();
  final Function(String) onImageSelect;
  final Function(String)? onFileSelect;
  final bool isImageCroppable;

  ModalImage({
    required this.onImageSelect,
    this.onFileSelect,
    required this.isImageCroppable,
  });

  Future<void> callGallery(BuildContext context,{String? type}) async {
    try {
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await processImage(image.path);
        if (type =='joinGroup')
          {Navigator.pop(context);}
      }
    } catch (e) {
      // log("${AppText.errorPckngImgs.tr} $e");
    }
  }

  Future<void> callCamera(BuildContext context,{String? type}) async {
    try {
      XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await processImage(image.path);
        if (type =='joinGroup')
        {Navigator.pop(context);}

      }
    } catch (e) {
      // log("${AppText.errorPckngImgFrmCamera.tr}$e");
    }
  }

  Future<void> callFilePicker(BuildContext context,) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String? filePath = result.files.single.path;
        if (onFileSelect != null && filePath != null) {
          onFileSelect!(filePath);
          // Navigator.pop(context);  // Close the dialog after file selection
        } else {
          // log(AppText.fileSelectCallbackNtProvided.tr);
        }
      }
    } catch (e) {
      // log("${AppText.errorPickingFile.tr}$e");
    }
  }

  Future<void> processImage(String imagePath) async {
    try {
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = '${dir.absolute.path}/temp.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        minHeight: 720,
        minWidth: 720,
        quality: 85,
      );

      if (result != null) {
        final newImage = File(result.path);

        if (isImageCroppable) {
          final croppedImagePath = await cropImage(newImage.path);
          if (croppedImagePath.isNotEmpty) {
            onImageSelect(croppedImagePath);
          }
        } else {
          onImageSelect(imagePath);
        }
      }
    } catch (e) {
      // log("${AppText.errorDuringImgProccesng.tr}$e");
    }
  }

  Future<String> cropImage(String imagePath) async {
    try {
      CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: imagePath,
        // aspectRatioPresets: [
        //   CropAspectRatioPreset.square,
        //   CropAspectRatioPreset.ratio3x2,
        //   CropAspectRatioPreset.ratio4x3,
        //   CropAspectRatioPreset.ratio16x9,
        // ],
        uiSettings: [
          AndroidUiSettings(

            toolbarTitle: AppText.cropImage,
            toolbarColor: AppColors.darkBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: AppText.cropImage,
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      return croppedImage?.path ?? "";
    } catch (e) {
      // log("${AppText.errorDuringImgCropping.tr}$e");
      return "";
    }
  }

  void mainBottomSheet(BuildContext context, {String? type, groupType}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.1),
                blurRadius: 10.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50.w,
                  height: 5.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                reausabletext(
                  "Choose an Option",
                  fontsize: 16,
                  fontweight: FontWeight.bold,
                ),
                SizedBox(height: 16.h),
                _buildOption(
                  icon: Icons.photo_library_rounded,
                  text: AppText.gallery.tr,
                  color: Colors.blueAccent,
                  onTap: () async {
                    await callGallery(context, type: groupType);
                  },
                ),
                _buildOption(
                  icon: Icons.camera_alt_rounded,
                  text: AppText.camera.tr,
                  color: Colors.orangeAccent,
                  onTap: () async {
                    await callCamera(context, type: groupType);
                  },
                ),
                if (type == "File")
                  _buildOption(
                    icon: Icons.insert_drive_file_rounded,
                    text: AppText.file,
                    color: Colors.teal,
                    onTap: () async {
                      await callFilePicker(context);
                    },
                  ),
                _buildOption(
                  icon: Icons.cancel_rounded,
                  text: AppText.cancel.tr,
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 22.sp),
            ),
            SizedBox(width: 14.w),
            reausabletext(
              text,
              fontsize: 14.sp,
              fontweight: FontWeight.w600,
              color: Colors.black87,
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
          ],
        ),
      ),
    );
  }


}
