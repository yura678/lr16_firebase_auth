import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const int maxImageBytes = 5 * 1024 * 1024;

  Future<String> uploadNoteImage({
    required Uint8List bytes,
    required String fileName,
    required String noteId,
    void Function(double progress)? onProgress,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final ext = _extension(fileName);
    final path =
        'users/${user.uid}/notes/$noteId/image_${DateTime.now().millisecondsSinceEpoch}.$ext';

    final task = _storage
        .ref(path)
        .putData(
          bytes,
          SettableMetadata(
            contentType: 'image/$ext',
            customMetadata: {'userId': user.uid, 'noteId': noteId},
          ),
        );

    task.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0) {
        onProgress?.call(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });

    final snapshot = await task;
    return snapshot.ref.getDownloadURL();
  }

  Future<void> deleteImage(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  String _extension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final ext = dot == -1 ? '' : fileName.substring(dot + 1).toLowerCase();
    return (ext == 'png' || ext == 'gif' || ext == 'webp') ? ext : 'jpeg';
  }
}
