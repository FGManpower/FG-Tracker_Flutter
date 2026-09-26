
import 'package:fgtracker/app/Core/constant/urls.dart';
import 'package:fgtracker/app/Core/util/http/http_util.dart';
import 'package:fgtracker/app/Model/walkie_talkie_trial_details_model.dart';

class WalkieTalkieTrialRepo {
  const WalkieTalkieTrialRepo();

  Future<WalkieTalkieTrialDetailsModel>
  getWalkieOverview() async {
    final response = await HttpUtil().get(
      Urls.walkieOverview,
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid Walkie-Talkie overview response.',
      );
    }

    return WalkieTalkieTrialDetailsModel.fromJson(
      Map<String, dynamic>.from(response),
    );
  }
}