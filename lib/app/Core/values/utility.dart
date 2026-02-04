class Utility {
  static bool isNullEmptyOrFalse(Object? o) {
    return o == null ||
        o == "0.0" ||
        o == "00:00" ||
        o == "0" ||
        o == 0 ||
        false == o ||
        "" == o ||
        "null" == o ||
        "false" == o;
  }

  static bool isNotNullEmptyOrFalse(Object? o) {
    return !isNullEmptyOrFalse(o);
  }

  static bool isImageUrl(String url) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final extension = url.split('.').last.toLowerCase();
    return imageExtensions.contains(extension);
  }
}
