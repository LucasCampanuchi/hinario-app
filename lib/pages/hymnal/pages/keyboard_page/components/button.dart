import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final void Function()? ontap;

  const Button({
    Key? key,
    this.text = '',
    this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
