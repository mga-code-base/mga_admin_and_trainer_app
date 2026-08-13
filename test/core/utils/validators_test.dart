import 'package:flutter_test/flutter_test.dart';
import 'package:mga_admin_and_trainer_app/core/utils/validators.dart';

void main() {
  group('Validators.isValidEmail', () {
    test('accepts a normal email', () {
      expect(Validators.isValidEmail('name@domain.com'), isTrue);
    });

    test('accepts an email with dots and hyphens in the local part', () {
      expect(Validators.isValidEmail('first.last-name@sub.domain.co'), isTrue);
    });

    test('trims surrounding whitespace before validating', () {
      expect(Validators.isValidEmail('  name@domain.com  '), isTrue);
    });

    test('rejects a value with no @', () {
      expect(Validators.isValidEmail('nameatdomain.com'), isFalse);
    });

    test('rejects a value with no domain extension', () {
      expect(Validators.isValidEmail('name@domain'), isFalse);
    });

    test('rejects an empty string', () {
      expect(Validators.isValidEmail(''), isFalse);
    });
  });

  group('Validators.isMobileNumber', () {
    test('accepts exactly 10 digits', () {
      expect(Validators.isMobileNumber('9876543210'), isTrue);
    });

    test('rejects fewer than 10 digits', () {
      expect(Validators.isMobileNumber('987654321'), isFalse);
    });

    test('rejects more than 10 digits', () {
      expect(Validators.isMobileNumber('98765432100'), isFalse);
    });

    test('rejects non-numeric input of the right length', () {
      expect(Validators.isMobileNumber('98765abcde'), isFalse);
    });

    test('trims surrounding whitespace before validating', () {
      expect(Validators.isMobileNumber('  9876543210  '), isTrue);
    });
  });

  group('Validators.isPincode', () {
    test('accepts exactly 6 digits', () {
      expect(Validators.isPincode('560001'), isTrue);
    });

    test('rejects fewer than 6 digits', () {
      expect(Validators.isPincode('5600'), isFalse);
    });

    test('rejects non-numeric input', () {
      expect(Validators.isPincode('56000A'), isFalse);
    });
  });

  group('Validators.isDigitsOnly', () {
    test('accepts a pure numeric string of any length', () {
      expect(Validators.isDigitsOnly('123'), isTrue);
      expect(Validators.isDigitsOnly('1234567890123'), isTrue);
    });

    test('rejects a string containing letters', () {
      expect(Validators.isDigitsOnly('123abc'), isFalse);
    });

    test('rejects an empty string', () {
      expect(Validators.isDigitsOnly(''), isFalse);
    });
  });

  group('Validators.isAlphanumericWithSpaces', () {
    test('accepts letters, numbers and spaces', () {
      expect(Validators.isAlphanumericWithSpaces('Branch 1 Downtown'), isTrue);
    });

    test('rejects special characters', () {
      expect(Validators.isAlphanumericWithSpaces('Branch #1!'), isFalse);
    });
  });

  group('Validators.isLettersWithSpaces', () {
    test('accepts letters and spaces only', () {
      expect(Validators.isLettersWithSpaces('John Doe'), isTrue);
    });

    test('rejects digits, unlike isAlphanumericWithSpaces', () {
      expect(Validators.isLettersWithSpaces('John Doe 2'), isFalse);
      expect(Validators.isAlphanumericWithSpaces('John Doe 2'), isTrue);
    });
  });

  group('Validators.isStrongPassword', () {
    test('accepts a password with a letter, a digit, a symbol, and 8+ chars', () {
      expect(Validators.isStrongPassword('Passw0rd!'), isTrue);
    });

    test('rejects a password missing a symbol', () {
      expect(Validators.isStrongPassword('Passw0rd'), isFalse);
    });

    test('rejects a password missing a digit', () {
      expect(Validators.isStrongPassword('Password!'), isFalse);
    });

    test('rejects a password shorter than 8 characters', () {
      expect(Validators.isStrongPassword('P0w!'), isFalse);
    });
  });

  group('Validators error-message helpers', () {
    test('mobileNumberError returns the required message when empty', () {
      expect(Validators.mobileNumberError(''), 'Mobile number is required');
      expect(Validators.mobileNumberError(null), 'Mobile number is required');
    });

    test('mobileNumberError returns the format message when invalid', () {
      expect(Validators.mobileNumberError('123'), 'Mobile number must be exactly 10 digits long');
    });

    test('mobileNumberError returns null when valid', () {
      expect(Validators.mobileNumberError('9876543210'), isNull);
    });

    test('mobileNumberError respects a custom required message', () {
      expect(
        Validators.mobileNumberError('', requiredMessage: 'Custom message'),
        'Custom message',
      );
    });

    test('pincodeError returns null when valid, message otherwise', () {
      expect(Validators.pincodeError('560001'), isNull);
      expect(Validators.pincodeError('12'), 'Pincode must be exactly 6 digits long');
      expect(Validators.pincodeError(''), 'Pincode is required');
    });

    test('emailError returns null when valid, message otherwise', () {
      expect(Validators.emailError('name@domain.com'), isNull);
      expect(Validators.emailError('not-an-email'), 'Provide a valid email address (e.g., name@domain.com)');
      expect(Validators.emailError(''), 'Email address is required');
    });

    test('requiredField returns the given message only when blank', () {
      expect(Validators.requiredField('', 'Field required'), 'Field required');
      expect(Validators.requiredField('   ', 'Field required'), 'Field required');
      expect(Validators.requiredField(null, 'Field required'), 'Field required');
      expect(Validators.requiredField('value', 'Field required'), isNull);
    });
  });
}
