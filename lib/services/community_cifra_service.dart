import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/connection/app_api.dart';
import '../models/cifra.dart';
import 'cifra_lookup_service.dart';
import 'client_identity_service.dart';
import 'database_service.dart';

/// Cifras enviadas pelo app (foto ou texto estilo Cifra Club).
///
/// Na API elas são cifras normais, então todo mundo recebe na próxima
/// sincronização. Aqui a gente já salva no aparelho de quem enviou, para
/// aparecer na hora (e funcionar offline).
class CommunityCifraService {
  static const _mineKey = 'community_cifras_mine_v1';

  CommunityCifraService._();
  static final CommunityCifraService instance = CommunityCifraService._();

  final ClientIdentityService _identity = ClientIdentityService.instance;
  final DatabaseService _db = DatabaseService();

  Future<Cifra> createFromImage({
    required File image,
    required String title,
    String? tone,
    void Function(double progress)? onProgress,
  }) async {
    final actor = await _identity.actorPayload();
    final ext = image.path.split('.').last.toLowerCase();
    final mime = ext == 'png'
        ? 'png'
        : ext == 'webp'
        ? 'webp'
        : 'jpeg';

    final form = FormData.fromMap({
      ...actor.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      'title': title,
      if (tone != null && tone.isNotEmpty) 'tone': tone,
      'file': await MultipartFile.fromFile(
        image.path,
        filename: 'cifra.${mime == 'jpeg' ? 'jpg' : mime}',
        contentType: DioMediaType('image', mime),
      ),
    });

    final data = await AppApi.postForm(
      'music-community/image',
      form,
      onProgress: onProgress == null
          ? null
          : (sent, total) {
              if (total > 0) onProgress(sent / total);
            },
    );
    final cifra = Cifra.fromJson(Map<String, dynamic>.from(data));
    return await _saveLocally(cifra, copyFrom: image);
  }

  Future<Cifra> createText({
    required String title,
    required String content,
    String? tone,
  }) async {
    final data = await AppApi.post(
      'music-community/text',
      data: {
        ...await _identity.actorPayload(),
        'title': title,
        'tone': tone,
        'content': content,
      },
    );
    final cifra = Cifra.fromJson(Map<String, dynamic>.from(data));
    return await _saveLocally(cifra, text: content);
  }

  Future<Cifra> updateText(
    Cifra cifra, {
    required String title,
    required String content,
    String? tone,
  }) async {
    final data = await AppApi.put(
      'music-community/${cifra.id}',
      data: {
        ...await _identity.actorPayload(),
        'title': title,
        'tone': tone ?? '',
        'content': content,
      },
    );
    final updated = Cifra.fromJson(Map<String, dynamic>.from(data));
    return await _saveLocally(updated, text: content);
  }

  Future<void> delete(Cifra cifra) async {
    await AppApi.delete(
      'music-community/${cifra.id}',
      data: await _identity.actorPayload(),
    );
    await _db.deleteCifra(cifra.id);
    if (cifra.localFilePath != null) {
      final file = File(cifra.localFilePath!);
      if (await file.exists()) await file.delete();
    }
    final mine = await _mine();
    mine.remove(cifra.id.toString());
    await _saveMine(mine);
    CifraLookupService.instance.invalidate();
  }

  Future<bool> isMine(int id) async => (await _mine()).contains(id.toString());

  Future<Set<int>> mineIds() async =>
      (await _mine()).map(int.tryParse).whereType<int>().toSet();

  // ---------------------------------------------------------------------------

  Future<Cifra> _saveLocally(Cifra cifra, {File? copyFrom, String? text}) async {
    final dir = Directory(
      '${(await getApplicationDocumentsDirectory()).path}/cifras',
    );
    if (!await dir.exists()) await dir.create(recursive: true);

    final filename = cifra.file?.filename ??
        '${cifra.id}.${cifra.kind == 'text' ? 'txt' : 'jpg'}';
    final path = '${dir.path}/$filename';

    if (copyFrom != null) {
      await copyFrom.copy(path);
    } else if (text != null) {
      await File(path).writeAsString(text);
    }

    await _db.insertCifra(cifra);
    await _db.updateCifraFilePath(cifra.id, path);

    final mine = await _mine();
    mine.add(cifra.id.toString());
    await _saveMine(mine);
    CifraLookupService.instance.invalidate();

    return cifra.copyWith(localFilePath: path);
  }

  Future<Set<String>> _mine() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_mineKey) ?? const []).toSet();
  }

  Future<void> _saveMine(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_mineKey, ids.toList());
  }
}
