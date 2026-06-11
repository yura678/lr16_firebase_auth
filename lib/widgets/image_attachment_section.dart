import 'dart:typed_data';

import 'package:flutter/material.dart';

class ImageAttachmentSection extends StatelessWidget {
  final bool isLoading;
  final bool hasImage;
  final Uint8List? pickedBytes;
  final String? currentImageUrl;
  final double uploadProgress;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const ImageAttachmentSection({
    super.key,
    required this.isLoading,
    required this.hasImage,
    this.pickedBytes,
    this.currentImageUrl,
    required this.uploadProgress,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  Widget _buildPreview() {
    const double height = 200;

    Widget framed(Widget child) =>
        ClipRRect(borderRadius: BorderRadius.circular(12), child: child);

    if (pickedBytes != null) {
      return framed(
        Image.memory(
          pickedBytes!,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    if (currentImageUrl != null) {
      return framed(
        Image.network(
          currentImageUrl!,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return SizedBox(
              height: height,
              child: Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, _) => Container(
            height: height,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 48),
          ),
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Attachment',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        _buildPreview(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onPickImage,
                icon: const Icon(Icons.photo_camera),
                label: Text(hasImage ? 'Change Photo' : 'Add Photo'),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: isLoading ? null : onRemoveImage,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
            ],
          ],
        ),
        if (isLoading && pickedBytes != null) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: uploadProgress),
          const SizedBox(height: 4),
          Text('Uploading… ${(uploadProgress * 100).toInt()}%'),
        ],
      ],
    );
  }
}
