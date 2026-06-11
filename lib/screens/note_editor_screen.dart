import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/note.dart';
import '../services/notes_repository.dart';
import '../utils/errors.dart';
import '../widgets/centered_form.dart';
import '../widgets/image_attachment_section.dart';
import '../widgets/primary_button.dart';

/// Create a new note or edit an existing one (TODO 3, 5).
/// Pass [note] to edit; omit it to create.
class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final NotesRepository _repo = NotesRepository();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  Uint8List? _pickedBytes;
  String? _pickedName;
  String? _currentImageUrl;
  String? _originalImageUrl;

  bool _isLoading = false;
  double _uploadProgress = 0;

  bool get _isEditing => widget.note != null;
  bool get _hasImage => _pickedBytes != null || _currentImageUrl != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _currentImageUrl = widget.note?.imageUrl;
    _originalImageUrl = widget.note?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (bytes.length > NotesRepository.maxImageBytes) {
      if (mounted) {
        final mb = (bytes.length / 1024 / 1024).toStringAsFixed(1);
        context.showSnackBar('Image too large ($mb MB). Max size is 5 MB.');
      }
      return;
    }

    setState(() {
      _pickedBytes = bytes;
      _pickedName = picked.name;
    });
  }

  void _removeImage() {
    setState(() {
      _pickedBytes = null;
      _pickedName = null;
      _currentImageUrl = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
    });

    try {
      await _repo.saveNote(
        id: _isEditing ? widget.note!.id : null,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        pickedBytes: _pickedBytes,
        fileName: _pickedName,
        currentImageUrl: _currentImageUrl,
        originalImageUrl: _originalImageUrl,
        onProgress: (p) => setState(() => _uploadProgress = p),
      );
      // The notes list updates itself via its stream.
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) context.showSnackBar(describeError(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Note' : 'New Note')),
      body: CenteredForm(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 4,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ImageAttachmentSection(
                  isLoading: _isLoading,
                  hasImage: _hasImage,
                  pickedBytes: _pickedBytes,
                  currentImageUrl: _currentImageUrl,
                  uploadProgress: _uploadProgress,
                  onPickImage: _pickImage,
                  onRemoveImage: _removeImage,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: _isEditing ? 'SAVE CHANGES' : 'CREATE NOTE',
                  onPressed: _save,
                  isLoading: _isLoading,
                  icon: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
