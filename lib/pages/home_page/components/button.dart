import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hinario_flutter/pages/home_page/store/home.store.dart';

class ButtonHome extends StatelessWidget {
  final String route;
  final String title;
  final IconData icon;

  const ButtonHome({
    Key? key,
    required this.route,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeStore controller = GetIt.I.get<HomeStore>();
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.all(
            Radius.circular(20.0), //                 <--- border radius here
          ),
        ),
        width: size.width * 0.45,
        height: size.width * 0.45,
        child: Stack(
          children: [
            InkWell(
              onTap: () => controller.setRoute(
                context,
                route,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: size.width * 0.18,
                        ),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Flexible(
                        flex: 2,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
