import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/initialize_model.dart';

class InitializeRepo {
  static Future<InitializeModel> getInitializeData() async {
    var response = await HttpUtil().get(Urls.initialize);
    return InitializeModel.fromJson(response);
  }
}
