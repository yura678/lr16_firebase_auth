// Unit tests for the Note model — no Firebase init needed, since `Timestamp`
// (from cloud_firestore) is a plain data class and we never touch
// FirebaseFirestore.instance here.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lr16_firebase_auth/models/note.dart';

void main() {
  group('Note', () {
    final created = DateTime(2026, 2, 13, 14, 30);
    final updated = DateTime(2026, 2, 13, 15, 0);

    final note = Note(
      id: 'abc123',
      title: 'Shopping List',
      content: 'Buy milk, eggs',
      createdAt: created,
      updatedAt: updated,
      userId: 'user1',
    );

    test('toJson stores Firestore Timestamps and omits id', () {
      final json = note.toJson();
      expect(json['title'], 'Shopping List');
      expect(json['userId'], 'user1');
      expect(json['createdAt'], isA<Timestamp>());
      expect((json['createdAt'] as Timestamp).toDate(), created);
      expect(json.containsKey('id'), isFalse);
    });

    test('fromJson(toJson) round-trips the fields', () {
      final restored = Note.fromJson(note.toJson(), note.id);
      expect(restored.id, note.id);
      expect(restored.title, note.title);
      expect(restored.content, note.content);
      expect(restored.userId, note.userId);
      expect(restored.createdAt, created);
      expect(restored.updatedAt, updated);
    });

    test('fromJson tolerates a null (pending) serverTimestamp', () {
      final restored = Note.fromJson(
        {'title': 'T', 'content': 'C', 'userId': 'u', 'createdAt': null},
        'id1',
      );
      expect(restored.title, 'T');
      // Falls back to a non-null DateTime instead of crashing on the cast.
      expect(restored.createdAt, isNotNull);
    });

    test('copyWith changes given fields and bumps updatedAt', () {
      final edited = note.copyWith(title: 'New Title');
      expect(edited.title, 'New Title');
      expect(edited.content, note.content); // unchanged
      expect(edited.id, note.id);
      expect(edited.createdAt, note.createdAt);
      expect(edited.updatedAt.isAfter(note.updatedAt), isTrue);
    });
  });
}
