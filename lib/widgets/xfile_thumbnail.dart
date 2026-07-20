import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Reads the picked file's bytes and renders via Image.memory, rather than
// dart:io's File — that class doesn't exist on Flutter Web, which is why
// photo previews were broken there (worked fine on Android, where File is
// available) despite looking identical in code.
class XFileThumbnail extends StatelessWidget {
  final XFile file;
  final double size;

  const XFileThumbnail({super.key, required this.file, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            width: size,
            height: size,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return Image.memory(
          snapshot.data!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
