import 'package:flutter_test/flutter_test.dart';
import 'package:mga_admin_and_trainer_app/models/equipment_model.dart';

void main() {
  group('Equipment.fromJson', () {
    test('parses a fully-populated catalog item', () {
      final equipment = Equipment.fromJson({
        'equipmentId': 'E-9',
        'name': 'Treadmill',
        'isInWorkingCondition': false,
        'targetMuscle': 'cardio',
      });

      expect(equipment.equipmentId, 'E-9');
      expect(equipment.name, 'Treadmill');
      expect(equipment.isInWorkingCondition, isFalse);
      expect(equipment.targetMuscle, 'cardio');
    });

    test('isInWorkingCondition defaults to true when missing', () {
      final equipment = Equipment.fromJson({'name': 'Bench'});
      expect(equipment.isInWorkingCondition, isTrue);
    });

    test('name defaults to an empty string when missing, not null', () {
      final equipment = Equipment.fromJson({});
      expect(equipment.name, '');
    });

    test('equipmentId and targetMuscle stay null when absent (pre-registration draft shape)', () {
      final equipment = Equipment.fromJson({'name': 'Squat Rack', 'targetMuscle': 'legs'});
      expect(equipment.equipmentId, isNull);
    });

    test('coerces a non-string equipmentId to String', () {
      final equipment = Equipment.fromJson({'equipmentId': 9, 'name': 'Bench'});
      expect(equipment.equipmentId, '9');
    });
  });

  group('Equipment.toJson', () {
    test('omits equipmentId and targetMuscle when null (the admin-signup draft case)', () {
      const equipment = Equipment(name: 'Treadmill', targetMuscle: 'cardio');
      final json = equipment.toJson();

      expect(json.containsKey('equipmentId'), isFalse);
      expect(json['name'], 'Treadmill');
      expect(json['isInWorkingCondition'], isTrue);
      expect(json['targetMuscle'], 'cardio');
    });

    test('includes equipmentId when present (the edit-existing-equipment case)', () {
      const equipment = Equipment(equipmentId: 'E-9', name: 'Treadmill', isInWorkingCondition: false);
      final json = equipment.toJson();

      expect(json['equipmentId'], 'E-9');
      expect(json['isInWorkingCondition'], isFalse);
      expect(json.containsKey('targetMuscle'), isFalse);
    });

    test('fromJson -> toJson round-trips the fields that were present', () {
      final original = {
        'equipmentId': 'E-1',
        'name': 'Lat Pulldown',
        'isInWorkingCondition': true,
        'targetMuscle': 'back',
      };
      final roundTripped = Equipment.fromJson(original).toJson();
      expect(roundTripped, original);
    });
  });
}
