import 'dart:io' show File;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReceiptImage extends StatelessWidget {
  final String imagePath;
  final double? height;
  final BoxFit fit;

  const ReceiptImage({
    super.key,
    required this.imagePath,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return const Center(
        child: Text('No receipt'),
      );
    }

    if (kIsWeb) {
      return Image.network(
        imagePath,
        height: height,
        fit: fit,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Center(
            child: Text(
              'Unable to load receipt',
            ),
          );
        },
      );
    }

    return Image.file(
      File(imagePath),
      height: height,
      fit: fit,
      errorBuilder: (
        context,
        error,
        stackTrace,
      ) {
        return const Center(
          child: Text(
            'Unable to load receipt',
          ),
        );
      },
    );
  }
}
