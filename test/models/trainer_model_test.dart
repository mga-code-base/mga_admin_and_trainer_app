import 'package:flutter_test/flutter_test.dart';
import 'package:mga_admin_and_trainer_app/models/trainer_model.dart';

void main() {
  group('Trainer.fromJson', () {
    test('parses a fully-populated trainer with a plain scalar trainerId', () {
      final trainer = Trainer.fromJson({
        'trainerId': '77',
        'name': 'Coach Sam',
        'username': 'csam',
        'emailAddress': 'sam@example.com',
        'mobileNumber': '9123456780',
        'isActive': true,
      });

      expect(trainer.trainerId, '77');
      expect(trainer.name, 'Coach Sam');
      expect(trainer.username, 'csam');
      expect(trainer.emailAddress, 'sam@example.com');
      expect(trainer.mobileNumber, '9123456780');
      expect(trainer.isActive, isTrue);
    });

    test('unwraps a Mongo-style {"\$numberLong": ...} trainerId', () {
      final trainer = Trainer.fromJson({
        'trainerId': {r'$numberLong': '9007199254740993'},
      });
      expect(trainer.trainerId, '9007199254740993');
    });

    test('unwraps a Mongo-style {"\$numberLong": ...} mobileNumber', () {
      final trainer = Trainer.fromJson({
        'trainerId': '77',
        'mobileNumber': {r'$numberLong': '9123456780'},
      });
      expect(trainer.mobileNumber, '9123456780');
    });

    test('a plain-scalar trainerId and a Mongo-wrapped one normalize to the same value', () {
      final plain = Trainer.fromJson({'trainerId': '-1'});
      final wrapped = Trainer.fromJson({
        'trainerId': {r'$numberLong': '-1'},
      });
      expect(plain.trainerId, wrapped.trainerId);
      expect(plain.trainerId, '-1');
    });

    test('missing trainerId normalizes to "N/A" rather than the literal string "null"', () {
      final trainer = Trainer.fromJson({});
      expect(trainer.trainerId, 'N/A');
    });

    test('missing mobileNumber stays null rather than becoming "N/A"', () {
      final trainer = Trainer.fromJson({'trainerId': '1'});
      expect(trainer.mobileNumber, isNull);
    });

    test('isActive defaults to true when missing (unlike Member, which defaults false)', () {
      final trainer = Trainer.fromJson({'trainerId': '1'});
      expect(trainer.isActive, isTrue);
    });

    test('isActive can be explicitly turned off', () {
      final trainer = Trainer.fromJson({'trainerId': '1', 'isActive': false});
      expect(trainer.isActive, isFalse);
    });
  });

  group('Trainer.normalizeId', () {
    test('returns "N/A" for null', () {
      expect(Trainer.normalizeId(null), 'N/A');
    });

    test('passes a plain scalar through as a string', () {
      expect(Trainer.normalizeId(42), '42');
      expect(Trainer.normalizeId('abc'), 'abc');
    });

    test('unwraps the Mongo \$numberLong map shape', () {
      expect(Trainer.normalizeId({r'$numberLong': '123'}), '123');
    });
  });
}
