import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Converts any thrown [error] into a short, user-friendly message.
///
/// Order matters: [FirebaseAuthException] is a subtype of [FirebaseException],
/// so it must be checked first.
String describeError(Object error) {
  if (error is FirebaseAuthException) {
    return _authMessage(error.code);
  }
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to do that.';
      case 'unavailable':
        return 'Service unavailable. Please check your connection.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'deadline-exceeded':
        return 'The request timed out. Please try again.';
      case 'unauthorized':
        return 'You do not have permission to upload this file.';
      case 'canceled':
        return 'Upload canceled.';
      case 'quota-exceeded':
        return 'Storage quota exceeded.';
      case 'object-not-found':
        return 'File not found.';
      case 'retry-limit-exceeded':
        return 'Upload timed out. Please try again.';
      default:
        return 'A database error occurred. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}

/// Maps a [FirebaseAuthException] code to a friendly message.
String _authMessage(String code) {
  switch (code) {
    case 'weak-password':
      return 'The password is too weak. Use at least 6 characters.';
    case 'email-already-in-use':
      return 'An account already exists for this email.';
    case 'user-not-found':
      return 'No user found with this email.';
    case 'wrong-password':
      return 'Wrong password provided.';
    case 'invalid-credential':
      return 'Invalid email or password.';
    case 'invalid-email':
      return 'Invalid email address format.';
    case 'user-disabled':
      return 'This user account has been disabled.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'operation-not-allowed':
      return 'This operation is not allowed.';
    case 'network-request-failed':
      return 'Network error. Please check your connection.';
    default:
      return 'An error occurred. Please try again.';
  }
}

/// Shows a [SnackBar] without the repeated `ScaffoldMessenger.of(context)`
/// boilerplate.
extension SnackBarMessenger on BuildContext {
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}
