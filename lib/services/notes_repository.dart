import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note.dart';
import 'firestore_service.dart';
import 'storage_service.dart';

/// Coordinates Firestore + Storage for notes so screens deal with one API and
/// don't have to know about upload paths or which file to delete.
class NotesRepository {
  final FirestoreService _firestore = FirestoreService();
  final StorageService _storage = StorageService();

  static const int maxImageBytes = StorageService.maxImageBytes;

  Query<Note> notesQuery() => _firestore.notesQuery();

  Future<void> saveNote({
    String? id,
    required String title,
    required String content,
    Uint8List? pickedBytes,
    String? fileName,
    String? currentImageUrl,
    String? originalImageUrl,
    void Function(double progress)? onProgress,
  }) async {
    final noteId = id ?? _firestore.newNoteId();

    String? imageUrl = currentImageUrl;
    if (pickedBytes != null) {
      imageUrl = await _storage.uploadNoteImage(
        bytes: pickedBytes,
        fileName: fileName ?? 'image.jpg',
        noteId: noteId,
        onProgress: onProgress,
      );
    }

    if (originalImageUrl != null && originalImageUrl != imageUrl) {
      await _storage.deleteImage(originalImageUrl);
    }

    if (id != null) {
      await _firestore.updateNote(noteId, title, content, imageUrl: imageUrl);
    } else {
      await _firestore.createNote(noteId, title, content, imageUrl: imageUrl);
    }
  }

  Future<void> deleteNote(Note note) async {
    if (note.imageUrl != null) {
      await _storage.deleteImage(note.imageUrl!);
    }
    await _firestore.deleteNote(note.id);
  }
}
