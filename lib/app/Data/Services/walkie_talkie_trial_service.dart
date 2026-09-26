
import '../Repositories/walkie_talkie_trial_details_repository.dart';
import '../../Model/walkie_talkie_trial_details_model.dart';

class WalkieTrialException implements Exception {
  final String message;

  const WalkieTrialException(this.message);

  @override
  String toString() => message;
}

class WalkieTalkieTrialService {
  WalkieTalkieTrialService({
    WalkieTalkieTrialRepo? repository,
  }) : _repository =
      repository ?? const WalkieTalkieTrialRepo();

  final WalkieTalkieTrialRepo _repository;

  Future<WalkieOverviewData> getOverview() async {
    try {
      final response =
      await _repository.getWalkieOverview();

      if (response.status != true) {
        throw WalkieTrialException(
          response.message ??
              'Unable to fetch Walkie-Talkie details.',
        );
      }

      final data = response.data;

      if (data == null) {
        throw const WalkieTrialException(
          'Walkie-Talkie overview data is missing.',
        );
      }

      if (data.access == null || data.trial == null) {
        throw const WalkieTrialException(
          'Incomplete Walkie-Talkie access information.',
        );
      }

      return data;
    } on WalkieTrialException {
      rethrow;
    } on FormatException {
      throw const WalkieTrialException(
        'Invalid response received from the server.',
      );
    } catch (_) {
      // Preserve networking exceptions so the controller
      // can distinguish timeout, authorization and
      // connection failures.
      rethrow;
    }
  }
}