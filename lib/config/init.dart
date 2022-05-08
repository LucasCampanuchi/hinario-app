import '../database/index.dart';
import 'mobx.dart';

Future<void> init() async {
  await DbConfig().initDatabase();
  await mobx();
}
