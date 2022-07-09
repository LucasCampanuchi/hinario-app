import 'package:flutter/material.dart';

import '../../../../../models/hymn.model.dart';

class ImageViewer extends StatelessWidget {
  final HymnModel hymn;
  const ImageViewer({
    Key? key,
    required this.hymn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: InteractiveViewer(
        clipBehavior: Clip.none,
        minScale: 1,
        maxScale: 4,
        panEnabled: false,
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            child: Image.asset(
              'assets/music_score/${hymn.number}.png',
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }
}
