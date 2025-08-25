class ChatImageUploadResponse {
  bool? status;
  String? filename;
  String? imageUrl;

  ChatImageUploadResponse({this.status, this.filename, this.imageUrl});

  ChatImageUploadResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    filename = json['filename'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['filename'] = this.filename;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
