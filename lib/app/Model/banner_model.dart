import 'package:fgtracker/app/Core/constant/const_res.dart';

class bannermodel {
  bool? success;
  String? message;
  List<BannerData>? data;

  bannermodel({this.success, this.message, this.data});

  bannermodel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <BannerData>[];
      json['data'].forEach((v) {
        data!.add(BannerData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BannerData {
  int? id;
  String? title;
  String? description;
  String? imageUrl;

  BannerData({this.id, this.title, this.description, this.imageUrl});

  BannerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    imageUrl = (json['imageUrl'] ??
            json['image'] ??
            json['image_url'] ??
            json['banner_image'])
        ?.toString();
  }

  /// Resolves the banner image URL to a full network URL if relative.
  String get resolvedImageUrl {
    if (imageUrl == null || imageUrl!.trim().isEmpty) return '';
    final clean = imageUrl!.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }
    final base = ConstRes.aImageBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final path = clean.replaceFirst(RegExp(r'^/+'), '');
    return '$base/$path';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['imageUrl'] = imageUrl;
    return data;
  }
}
