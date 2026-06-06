import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note.dart';
import '../services/firestore_service.dart';
import '../utils/errors.dart';
import 'note_editor_screen.dart';

/// Real-time list of the user's notes with create/edit/delete.
///
/// [FirestoreListView] (firebase_ui_firestore) paginates with Firestore cursors
/// and fetches the next page as the user scrolls, so it only reads the
/// documents actually shown — far fewer reads than re-querying a growing limit.
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final FirestoreService _service = FirestoreService();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy  HH:mm');

  void _openEditor([Note? note]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteEditorScreen(note: note)),
    );
  }

  Future<void> _confirmDelete(Note note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note'),
        content: Text('Delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    try {
      await _service.deleteNote(note.id);
    } catch (e) {
      if (mounted) context.showSnackBar(describeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ),
      body: FirestoreListView<Note>(
        query: _service.notesQuery(),
        pageSize: 10,
        padding: const EdgeInsets.symmetric(vertical: 8),
        loadingBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, _) =>
            Center(child: Text(describeError(error))),
        emptyBuilder: (context) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('No notes yet'),
              SizedBox(height: 4),
              Text('Tap + to create your first note'),
            ],
          ),
        ),
        itemBuilder: (context, snapshot) {
          final note = snapshot.data();
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.sticky_note_2),
              title: Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateFormat.format(note.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              onTap: () => _openEditor(note),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(note),
              ),
            ),
          );
        },
      ),
    );
  }
}
