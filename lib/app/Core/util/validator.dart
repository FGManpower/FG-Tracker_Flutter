import 'package:fgtracker/l10n/l10n.dart';




class Validator {
  static String? validateEmail(String? value) {
    String patttern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(patttern);
    value = value?.trim();
    if (value == null || value.isEmpty) {
      return appL10n.validation_emailEmpty;
    } else if (!regExp.hasMatch(value)) {
      return appL10n.validation_emailInvalid;
    } else {
      return null;
    }
  }

  static String? validateOptionalEmail(String? value) {
    value = value?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    String patttern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = RegExp(patttern);
    if (!regExp.hasMatch(value)) {
      return appL10n.validation_emailInvalid;
    }
    return null;
  }

  static String? validate({String? value, title}) {
    if (value == null || value.isEmpty || value=="") {
      return appL10n.validation_required("$title");
    }
    return null;
  }

  static String? validatePhone(String? value) {
    value = value?.trim();
    final RegExp regExp = RegExp(r'^[0-9]{10}$');

    if (value == null || value.isEmpty) {
      return "Phone number cannot be empty";
    } else if (!regExp.hasMatch(value)) {
      return "Please enter a valid 10-digit phone number";
    } else {
      return null;
    }
  }



}

