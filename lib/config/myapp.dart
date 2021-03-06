import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../layout/colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      debugShowCheckedModeBanner: false,
      title: 'Hinário',
      theme: ThemeData(
        primarySwatch: AppColors.kToDark,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
