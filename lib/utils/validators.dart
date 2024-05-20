class Validators {
  static String? emptyValidator(String? text, message) {
    if (text == null || text.isEmpty) {
      return message;
    }

    return null;
  }

  static String? passwordValidator(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password required';
    }

    bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(new RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
        password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length >= 8;

    if (!hasMinLength) {
      return 'Password must be at least 8 characters';
    }
    if (!hasUppercase) {
      return 'Password must have uppercase characters';
    }
    if (!hasLowercase) {
      return 'Password must have lowercase characters';
    }
    if (!hasDigits) {
      return 'Password must have at lease 1 digit';
    }
    // if (hasSpecialCharacters) {
    //   return 'Password must must not contain any special characters';
    // }
    return null;
  }
}
