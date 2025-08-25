

import 'dart:developer';

import 'package:fgtracker/app/Core/theme/AppText.dart';
import 'package:fgtracker/app/Core/values/colors.dart';
import 'package:fgtracker/app/global_widget/common_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  void mainBottomSheet(BuildContext context, {String? type,groupType}) {
    showModalBottomSheet(backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title:  reausabletext(AppText.gallery.tr),
                onTap: () async {
                  await callGallery(context,type: groupType,);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera),
                title:  reausabletext(AppText.camera.tr),
                onTap: () async {
                  await callCamera(context,type: groupType);
                },
              ),
              type == "File"
                  ? ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title:  reausabletext(AppText.file),
                onTap: () async {
                  await callFilePicker(context);
                },
              )
                  : const SizedBox(),
              ListTile(
                leading: const Icon(Icons.cancel),
                title:  reausabletext(AppText.cancel.tr),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
