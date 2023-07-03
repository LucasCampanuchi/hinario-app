import 'package:flutter/material.dart';
import 'package:hinario_flutter/models/image.model.dart';

import '../components/pinch_zoom_image.dart';

class ReadImagePage extends StatelessWidget {
  final ImageModel image;
  const ReadImagePage({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PinchZoomImage(
                url: image.path,
              ),
            ],
          ),
          Positioned(
            left: 20,
            top: 35,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
