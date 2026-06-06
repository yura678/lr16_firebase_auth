// Unit tests for describeError — no Firebase init needed; FirebaseAuthException
// and FirebaseException are plain data classes.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lr16_firebase_auth/utils/errors.dart';

void main() {
  group('describeError', () {
    test('maps Firebase auth codes to friendly messages', () {
      expect(
        describeError(FirebaseAuthException(code: 'email-already-in-use')),
        'An account already exists for this email.',
      );
      expect(
        describeError(FirebaseAuthException(code: 'invalid-credential')),
        'Invalid email or password.',
      );
      expect(
        describeError(FirebaseAuthException(code: 'network-request-failed')),
        'Network error. Please check your connection.',
      );
    });

    test('uses an auth fallback for unknown auth codes', () {
      expect(
        describeError(FirebaseAuthException(code: 'something-unexpected')),
        'An error occurred. Please try again.',
      );
    });

    test('maps Firestore errors to friendly messages', () {
      expect(
        describeError(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
        'You do not have permission to do that.',
      );
    });

    test('falls back to a generic message for arbitrary errors', () {
      expect(
        describeError(Exception('boom')),
        'Something went wrong. Please try again.',
      );
    });
  });
}
