import 'package:fgtracker/l10n/l10n.dart';
import '../Repositories/walkie_talkie_trial_details_repository.dart';
import '../../Model/walkie_talkie_trial_details_model.dart';

class WalkieTrialException implements Exception {
  final String message;

  const WalkieTrialException(this.message);

  @override
  String toString() => message;
}

class WalkieTalkieTrialService {
  final WalkieTalkieTrialRepo _repository = const WalkieTalkieTrialRepo();

  Future<WalkieOverviewData> getOverview() async {
    try {
      final response = await _repository.getWalkieOverview();

      if (!response.isSuccessful) {
        throw WalkieTrialException(
          response.message ?? appL10n.walkiePlan_trialErrFetchDetails,
        );
      }

      final data = response.data;

      if (data == null) {
        throw WalkieTrialException(
          appL10n.walkiePlan_trialErrOverviewMissing,
        );
      }

      if (data.access == null) {
        throw WalkieTrialException(
          appL10n.walkiePlan_trialErrAccessMissing,
        );
      }

      return data;
    } on WalkieTrialException {
      rethrow;
    } on FormatException {
      throw WalkieTrialException(
        appL10n.walkiePlan_trialErrInvalidResponse,
      );
    } catch (_) {
      rethrow;
    }
  }
}