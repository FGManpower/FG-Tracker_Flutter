class ChatImageUploadResponse {
  bool? status;
  String? filename;
  String? originalName;
  String? imageUrl;

  ChatImageUploadResponse({this.status, this.filename, this.imageUrl,this.originalName});

  ChatImageUploadResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    filename = json['filename'];
    originalName = json['originalName'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['filename'] = this.filename;
    data['originalName'] = this.originalName;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}
