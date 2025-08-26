import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../../../models/cifra.dart';

class CifraViewPage extends StatelessWidget {
  final Cifra cifra;

  const CifraViewPage({Key? key, required this.cifra}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cifra.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: cifra.localFilePath != null && File(cifra.localFilePath!).existsSync()
          ? PDFView(
              filePath: cifra.localFilePath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: false,
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Arquivo não encontrado'),
                  Text('Tente sincronizar novamente'),
                ],
              ),
            ),
    );
  }
}