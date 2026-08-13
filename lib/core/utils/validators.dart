class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp _alphanumericWithSpaces = RegExp(r'^[a-zA-Z0-9\s]+$');
  static final RegExp _lettersWithSpaces = RegExp(r'^[a-zA-Z\s]+$');
  static final RegExp _digitsOnly = RegExp(r'^\d+$');
  static final RegExp _strongPassword =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');

  static bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());

  static bool isAlphanumericWithSpaces(String value) => _alphanumericWithSpaces.hasMatch(value);

  static bool isLettersWithSpaces(String value) => _lettersWithSpaces.hasMatch(value);

  static bool isDigitsOnly(String value) => _digitsOnly.hasMatch(value);

  static bool isStrongPassword(String value) => _strongPassword.hasMatch(value);

  static bool isMobileNumber(String value) {
    final trimmed = value.trim();
    return trimmed.length == 10 && int.tryParse(trimmed) != null;
  }

  static bool isPincode(String value) {
    final trimmed = value.trim();
    return trimmed.length == 6 && int.tryParse(trimmed) != null;
  }

  static String? requiredField(String? value, String message) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  static String? mobileNumberError(String? value, {String requiredMessage = 'Mobile number is required'}) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    return isMobileNumber(value) ? null : 'Mobile number must be exactly 10 digits long';
  }

  static String? pincodeError(String? value, {String requiredMessage = 'Pincode is required'}) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    return isPincode(value) ? null : 'Pincode must be exactly 6 digits long';
  }

  static String? emailError(String? value, {String requiredMessage = 'Email address is required'}) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    return isValidEmail(value) ? null : 'Provide a valid email address (e.g., name@domain.com)';
  }
}
