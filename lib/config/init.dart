import '../database/index.dart';
import 'init_book.dart';
import 'mobx.dart';

Future<void> init() async {
  await DbConfig().initDatabase();
  await mobx();
  await initBook();
}
