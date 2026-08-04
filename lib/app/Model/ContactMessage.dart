import 'dart:convert';

class ContactMessage {
  final String name;
  final String phone;

  const ContactMessage({
    required this.name,
    required this.phone,
  });

  factory ContactMessage.fromJson(Map<String, dynamic> json) {
    return ContactMessage(
      name: json["name"] ?? "",
      phone: json["phone"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
    };
  }

  String toContent() {
    return jsonEncode(toJson());
  }

  factory ContactMessage.fromContent(String content) {
    return ContactMessage.fromJson(
      jsonDecode(content) as Map<String, dynamic>,
    );
  }
}