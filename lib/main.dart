import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'config/init.dart';
import 'config/myapp.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await init();

  runApp(
    ModularApp(
      module: AppModule(),
      child: const MyApp(),
    ),
  );
}
