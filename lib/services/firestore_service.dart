import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/note.dart';

/// CRUD for the current user's notes (TODO 3–6, 9).
///
/// Data is user-specific: everything lives under `users/{uid}/notes`, so each
/// user only ever touches their own collection (enforced by Security Rules).
class FirestoreService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'default',
  );

  CollectionReference<Map<String, dynamic>> _notesRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    return _firestore.collection('users').doc(user.uid).collection('notes');
  }

  Future<void> createNote(String title, String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _notesRef().add({
      'title': title,
      'content': content,
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Typed query of the user's notes, newest first.
  ///
  /// `FirestoreListView` paginates over this with cursors, fetching one page at
  /// a time as the user scrolls, so only the documents actually shown are read
  /// (and updates stay real-time).
  Query<Note> notesQuery() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .withConverter<Note>(
          fromFirestore: (snapshot, _) =>
              Note.fromJson(snapshot.data()!, snapshot.id),
          toFirestore: (note, _) => note.toJson(),
        );
  }

  Future<void> updateNote(String noteId, String title, String content) async {
    await _notesRef().doc(noteId).update({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String noteId) async {
    await _notesRef().doc(noteId).delete();
  }
}
