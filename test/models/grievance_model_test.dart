import 'package:flutter_test/flutter_test.dart';
import 'package:mga_admin_and_trainer_app/models/grievance_model.dart';

void main() {
  group('Grievance.fromJson', () {
    test('parses a fully-populated closed ticket', () {
      final grievance = Grievance.fromJson({
        'grievanceId': 'G-101',
        'branchId': 'B-01',
        'issueType': 'Equipment',
        'description': 'Treadmill belt is torn.',
        'resolution': 'Replaced belt on 12 Aug.',
        'date': '2026-08-01',
        'closureDate': '2026-08-12',
      });

      expect(grievance.grievanceId, 'G-101');
      expect(grievance.branchId, 'B-01');
      expect(grievance.issueType, 'Equipment');
      expect(grievance.description, 'Treadmill belt is torn.');
      expect(grievance.resolution, 'Replaced belt on 12 Aug.');
      expect(grievance.date, '2026-08-01');
      expect(grievance.closureDate, '2026-08-12');
      expect(grievance.isClosed, isTrue);
    });

    test('an open ticket (no closureDate) reports isClosed as false', () {
      final grievance = Grievance.fromJson({
        'grievanceId': 'G-102',
        'branchId': 'B-01',
        'issueType': 'Staff',
        'description': 'Late trainer arrival.',
        'resolution': '',
        'date': '2026-08-10',
      });

      expect(grievance.closureDate, isNull);
      expect(grievance.isClosed, isFalse);
    });

    test('substitutes the same fallback text the screen used to apply inline', () {
      final grievance = Grievance.fromJson({});

      expect(grievance.grievanceId, 'N/A');
      expect(grievance.branchId, 'Unknown Branch');
      expect(grievance.issueType, 'General Issue');
      expect(grievance.description, 'No text summary provided.');
      expect(grievance.resolution, 'Awaiting management audit.');
      expect(grievance.date, '');
      expect(grievance.closureDate, isNull);
    });

    test('coerces a non-string grievanceId (e.g. a raw int from the backend) to String', () {
      final grievance = Grievance.fromJson({'grievanceId': 101});
      expect(grievance.grievanceId, '101');
    });
  });
}
