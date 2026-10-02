import 'dart:io';
import 'package:fgtracker/app/Model/status_model.dart';
import 'package:get/get.dart';


class StatusApiService extends GetConnect {
  final String Function() tokenProvider;
  final String apiBaseUrl;

  StatusApiService({
    required this.apiBaseUrl,
    required this.tokenProvider,
  });

  @override
  void onInit() {
    httpClient.baseUrl = apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 30);
    httpClient.addRequestModifier<dynamic>((request) {
      final token = tokenProvider();
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });
    super.onInit();
  }

  Future<List<ContactStatusGroupModel>> fetchStatusFeed() async {
    final response = await get('/api/status/feed');
    if (response.status.hasError || response.body == null) {
      throw Exception(response.statusText ?? 'Failed to fetch status feed');
    }
    final rawList = response.body is Map
        ? (response.body['data'] as List<dynamic>? ?? [])
        : (response.body as List<dynamic>? ?? []);
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(ContactStatusGroupModel.fromJson)
        .toList();
  }

  Future<List<StatusItemModel>> fetchMyStatuses() async {
    final response = await get('/api/status/my-status');
    if (response.status.hasError || response.body == null) {
      throw Exception(response.statusText ?? 'Failed to fetch my statuses');
    }
    final rawList = response.body is Map
        ? (response.body['data'] as List<dynamic>? ?? [])
        : (response.body as List<dynamic>? ?? []);
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(StatusItemModel.fromJson)
        .toList();
  }

  Future<StatusItemModel?> createStatus({
    required String mediaType,
    required String privacy,
    String? caption,
    String? backgroundColor,
    String? location,
    File? mediaFile,
  }) async {
    final formMap = <String, dynamic>{
      'type': mediaType,
      'mediaType': mediaType,
      'privacy': privacy,
      if (caption != null && caption.isNotEmpty) 'caption': caption,
      if (caption != null && caption.isNotEmpty) 'text': caption,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (location != null && location.isNotEmpty) 'location': location,
    };

    if (mediaFile != null) {
      final fileName = mediaFile.path.split('/').last;
      formMap['file'] = MultipartFile(mediaFile, filename: fileName);
    }

    final formData = FormData(formMap);
    final response = await post('/api/status/create', formData);

    if (response.status.hasError) {
      throw Exception(response.statusText ?? 'Failed to create status');
    }

    if (response.body is Map && response.body['data'] is Map) {
      return StatusItemModel.fromJson(
        Map<String, dynamic>.from(response.body['data']),
      );
    }
    return null;
  }

  Future<bool> recordViewHttp({
    required int statusId,
    String? reactionEmoji,
  }) async {
    final response = await post(
      '/api/status/$statusId/view',
      {
        if (reactionEmoji != null && reactionEmoji.isNotEmpty)
          'reactionEmoji': reactionEmoji,
      },
    );
    return !response.status.hasError;
  }

  Future<bool> replyToStatus({
    required int statusId,
    required String message,
  }) async {
    final response = await post(
      '/api/status/$statusId/reply',
      {'message': message, 'reply': message},
    );
    return !response.status.hasError;
  }

  Future<bool> deleteStatus(int statusId) async {
    final response = await delete('/api/status/$statusId');
    return !response.status.hasError;
  }
}