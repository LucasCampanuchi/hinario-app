import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../api/connection/app_api.dart';
import '../models/cifra.dart';
import 'cifra_lookup_service.dart';
import 'database_service.dart';

/// Baixa UMA cifra pelo id, na hora (ex.: alguém mandou uma foto na sala
/// ao vivo e ela ainda não está no meu aparelho). Não espera a sincronização.
class CifraDownloadService {
  CifraDownloadService._();
  static final CifraDownloadService instance = CifraDownloadService._();

  final DatabaseService _db = DatabaseService();
  final Map<int, Future<Cifra?>> _inFlight = {};

  static final Dio _http = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 45),
      responseType: ResponseType.bytes,
    ),
  );

  /// [title]/[kind]/[fileUrl]: quando a sala já mandou esses dados, não
  /// precisa consultar a API antes de baixar.
  Future<Cifra?> ensure(
    int id, {
    String? title,
    String? kind,
    String? fileUrl,
  }) {
    return _inFlight[id] ??= _download(
      id,
      title: title,
      kind: kind,
      fileUrl: fileUrl,
    ).whenComplete(() => _inFlight.remove(id));
  }

  Future<Cifra?> _download(
    int id, {
    String? title,
    String? kind,
    String? fileUrl,
  }) async {
    final existing = await CifraLookupService.instance.byId(id);
    if (existing?.localFilePath != null &&
        await File(existing!.localFilePath!).exists()) {
      return existing;
    }

    try {
      Cifra cifra;
      if (fileUrl != null && title != null) {
        final now = DateTime.now().toIso8601String();
        cifra = Cifra(
          id: id,
          title: title,
          createdAt: now,
          updatedAt: now,
          kind: kind,
          file: CifraFile(
            id: 0,
            filename: fileUrl.split('/').last,
            url: fileUrl,
            size: 0,
          ),
        );
      } else {
        final data = await AppApi.get('music-external/$id');
        cifra = Cifra.fromJson(Map<String, dynamic>.from(data));
      }
      final url = cifra.file?.url;
      if (url == null) return null;

      final bytes = await _http.get<List<int>>(url);
      final dir = Directory(
        '${(await getApplicationDocumentsDirectory()).path}/cifras',
      );
      if (!await dir.exists()) await dir.create(recursive: true);
      final path = '${dir.path}/${cifra.file!.filename}';
      await File(path).writeAsBytes(bytes.data ?? const []);

      await _db.insertCifra(cifra);
      await _db.updateCifraFilePath(cifra.id, path);
      CifraLookupService.instance.invalidate();
      return cifra.copyWith(localFilePath: path);
    } catch (_) {
      return null;
    }
  }
}
