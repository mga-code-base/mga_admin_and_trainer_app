import 'package:flutter_test/flutter_test.dart';
import 'package:mga_admin_and_trainer_app/models/member_model.dart';

void main() {
  group('Member.fromJson', () {
    test('parses a fully-populated active member', () {
      final member = Member.fromJson({
        'memberId': '55',
        'name': 'Asha Rao',
        'mobileNumber': '9876543210',
        'emailAddress': 'asha@example.com',
        'localityPincode': '560001',
        'membershipEndDate': '2026-12-31',
        'trainerAssigned': 'T-9',
        'isActive': true,
      });

      expect(member.memberId, '55');
      expect(member.name, 'Asha Rao');
      expect(member.mobileNumber, '9876543210');
      expect(member.emailAddress, 'asha@example.com');
      expect(member.localityPincode, '560001');
      expect(member.membershipEndDate, '2026-12-31');
      expect(member.trainerAssigned, 'T-9');
      expect(member.isActive, isTrue);
    });

    test('optional fields are null, not a display fallback — screens apply their own text', () {
      final member = Member.fromJson({'memberId': '56'});

      expect(member.name, isNull);
      expect(member.mobileNumber, isNull);
      expect(member.emailAddress, isNull);
      expect(member.localityPincode, isNull);
      expect(member.membershipEndDate, isNull);
      expect(member.trainerAssigned, isNull);
    });

    test('memberId falls back to "N/A" when missing, matching the original screen behavior', () {
      final member = Member.fromJson({});
      expect(member.memberId, 'N/A');
    });

    test('isActive defaults to false and requires an exact `true`, not just truthiness', () {
      expect(Member.fromJson({}).isActive, isFalse);
      expect(Member.fromJson({'isActive': false}).isActive, isFalse);
      expect(Member.fromJson({'isActive': 'true'}).isActive, isFalse); // string, not bool -> not active
      expect(Member.fromJson({'isActive': true}).isActive, isTrue);
    });

    test('coerces a non-string memberId to String', () {
      final member = Member.fromJson({'memberId': 55});
      expect(member.memberId, '55');
    });
  });
}
