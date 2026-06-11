// Unit tests for Validators — pure functions, no Firebase needed.

import 'package:flutter_test/flutter_test.dart';

import 'package:lr16_firebase_auth/utils/validators.dart';

void main() {
  group('Validators', () {
    test('requiredField rejects empty/whitespace/null, accepts text', () {
      expect(Validators.requiredField(''), isNotNull);
      expect(Validators.requiredField('   '), isNotNull);
      expect(Validators.requiredField(null), isNotNull);
      expect(Validators.requiredField('x'), isNull);
    });

    test('email requires an @', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('foo'), isNotNull);
      expect(Validators.email('a@b.com'), isNull);
    });

    test('password requires at least 6 characters', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('confirmPassword must match the original', () {
      expect(Validators.confirmPassword('a', 'b'), isNotNull);
      expect(Validators.confirmPassword('abc', 'abc'), isNull);
    });
  });
}
