class ChatImageUploadResponse {
  bool? status;
  String? filename;
  String? originalName;
  String? imageUrl;

  String? videoUrl;
  String? thumbnail;
  String? duration;

  ChatImageUploadResponse({
    this.status,
    this.filename,
    this.originalName,
    this.imageUrl,
    this.videoUrl,
    this.thumbnail,
    this.duration,
  });

  ChatImageUploadResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    status = json['status'];
    filename = json['filename'];
    originalName = json['originalName'];
    imageUrl = json['imageUrl'];

    videoUrl = json['videoUrl'];
    thumbnail = json['thumbnail'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'filename': filename,
      'originalName': originalName,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'thumbnail': thumbnail,
      'duration': duration,
    };
  }
}