import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hinario_flutter/layout/colors.dart';

class ImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit? fit;
  final BorderRadiusGeometry? borderRadius;
  final double? opacity;

  const ImageWidget({
    Key? key,
    this.imageUrl,
    this.fit,
    this.borderRadius,
    this.opacity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl ?? "http://via.placeholder.com/200x150",
        imageBuilder: (context, imageProvider) => ColorFiltered(
          colorFilter: ColorFilter.mode(
            Color.fromRGBO(0, 0, 0, opacity ?? 0.0),
            BlendMode.darken,
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: fit ?? BoxFit.cover,
              ),
            ),
          ),
        ),
        placeholder: (context, url) => SizedBox.expand(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryWithOpacity,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
        errorWidget: (context, url, error) => SizedBox.expand(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
