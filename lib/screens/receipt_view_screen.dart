import 'package:flutter/material.dart';

import '../widgets/receipt_image.dart';

class ReceiptViewScreen extends StatelessWidget {
  final String imagePath;

  const ReceiptViewScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Receipt Preview',
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          child: ReceiptImage(
            imagePath: imagePath,
          ),
        ),
      ),
    );
  }
}