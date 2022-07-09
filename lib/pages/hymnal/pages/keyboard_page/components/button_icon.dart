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
    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        onTap: ontap,
        child: SizedBox(
          width: size.width * 0.18,
          height: size.width * 0.27,
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
