// Unit tests for the auth error-message mapping.
//
// The UI is driven by Firebase (AuthWrapper listens to authStateChanges), so a
// widget smoke test would require initializing/mocking Firebase. Instead we
// test AuthErrors, which is pure and has no Firebase dependency.

import 'package:flutter_test/flutter_test.dart';

import 'package:lr16_firebase_auth/utils/auth_errors.dart';

void main() {
  group('AuthErrors.getErrorMessage', () {
    test('maps known Firebase auth codes to friendly messages', () {
      expect(
        AuthErrors.getErrorMessage('email-already-in-use'),
        'An account already exists for this email.',
      );
      expect(
        AuthErrors.getErrorMessage('invalid-credential'),
        'Invalid email or password.',
      );
      expect(
        AuthErrors.getErrorMessage('network-request-failed'),
        'Network error. Please check your connection.',
      );
    });

    test('falls back to a generic message for unknown codes', () {
      expect(
        AuthErrors.getErrorMessage('something-unexpected'),
        'An error occurred. Please try again.',
      );
    });
  });
}
