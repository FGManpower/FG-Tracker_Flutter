import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/walkie_plan_model.dart';

class WalkiePlanRepo {
  static Future<WalkiePlansResponseModel> getPlans({required String planType}) async {
    var response = await HttpUtil().get(
      Urls.walkiePlans,
      data: {'planType': planType},
    );
    return WalkiePlansResponseModel.fromJson(response);
  }
}
