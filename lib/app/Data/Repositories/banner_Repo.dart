import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/banner_model.dart';

class BannerRepo {
  static Future<bannermodel> getBanner() async {
    var response = await HttpUtil().get(Urls.banner);
    return bannermodel.fromJson(response);
  }
}
