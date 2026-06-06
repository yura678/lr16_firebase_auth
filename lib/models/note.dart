import 'package:cloud_firestore/cloud_firestore.dart';

/// A single note stored at `users/{userId}/notes/{id}` (TODO 2).
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory Note.fromJson(Map<String, dynamic> json, String id) {
    return Note(
      id: id,
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      // serverTimestamp() resolves on the backend, so a freshly-created doc has
      // a null timestamp locally for a moment — parse null-safely instead of a
      // direct cast (which would throw during that window).
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: (json['userId'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
    };
  }

  Note copyWith({String? title, String? content}) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      userId: userId,
    );
  }
}
