import 'package:flutter/material.dart';

class ButtonIcon extends StatelessWidget {
  final IconData icon;
  final double? sizeIcon;
  final void Function()? ontap;

  const ButtonIcon({
    Key? key,
    required this.icon,
    this.ontap,
    this.sizeIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width * 0.18;
    final double height =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? size.width * 0.27
            : size.width * 0.15;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        onTap: ontap,
        child: SizedBox(
          width: width,
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: sizeIcon,
              )
            ],
          ),
        ),
      ),
    );
  }
}
