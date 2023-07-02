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
    double width = size.width *
        (MediaQuery.of(context).orientation == Orientation.portrait
            ? 0.25
            : 0.20);

    return SizedBox(
      width: width + 16,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 62, 90, 134),
                  //color: AppColors.primary,
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      20.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(5.0, 5.0),
                      blurRadius: 5.0,
                    ),
                  ],
                ),
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
                                  size: size.width * 0.12,
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
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
