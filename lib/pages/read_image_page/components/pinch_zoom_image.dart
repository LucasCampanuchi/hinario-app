import 'package:flutter/material.dart';

class PinchZoomImage extends StatefulWidget {
  final String url;
  final bool isNetwork;
  const PinchZoomImage({
    Key? key,
    required this.url,
    this.isNetwork = false,
  }) : super(key: key);

  @override
  _PinchZoomImageState createState() => _PinchZoomImageState();
}

class _PinchZoomImageState extends State<PinchZoomImage>
    with SingleTickerProviderStateMixin {
  final double minScale = 1;
  final double maxScale = 4;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          minScale: minScale,
          maxScale: maxScale,
          panEnabled: true,
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              child: widget.isNetwork
                  ? Image.network(
                      widget.url,
                      fit: BoxFit.fitHeight,
                    )
                  : Image.asset(
                      widget.url,
                      fit: BoxFit.fitHeight,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
