import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/connection/app_api.dart';

/// Identidade anônima do aparelho, no mesmo esquema do PWA:
/// um client_id aleatório salvo localmente + um nome público.
/// O app sempre se identifica como client_type = 'app'.
class ClientIdentityService {
  static const String clientType = 'app';
  static const String _clientIdKey = 'client_identity_id';
  static const String _nameKey = 'client_identity_name';

  ClientIdentityService._();
  static final ClientIdentityService instance = ClientIdentityService._();

  String? _clientId;
  String? _name;

  Future<String> getClientId() async {
    if (_clientId != null) return _clientId!;
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_clientIdKey);
    if (id == null || id.isEmpty) {
      id = 'app-${_uuidV4()}';
      await prefs.setString(_clientIdKey, id);
    }
    _clientId = id;
    return id;
  }

  Future<String?> getName() async {
    if (_name != null) return _name;
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey);
    return _name;
  }

  Future<void> setName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, trimmed);
    _name = trimmed;

    // Melhor esforço: registra/atualiza o nome no client_profiles
    try {
      final id = await getClientId();
      await AppApi.patch(
        'client-profile/$id',
        data: {'name': trimmed, 'client_type': clientType},
      );
    } catch (_) {
      // será enviado de novo junto com a próxima playlist/sala
    }
  }

  /// Campos de identificação que vão em todo POST/PUT das rotas novas.
  Future<Map<String, dynamic>> actorPayload() async {
    return {
      'client_id': await getClientId(),
      'client_type': clientType,
      'name': await getName(),
    };
  }

  /// Garante que a pessoa tem nome antes de publicar/entrar numa sala.
  /// Retorna false se ela cancelar.
  Future<bool> ensureName(BuildContext context) async {
    final current = await getName();
    if (current != null && current.isNotEmpty) return true;
    if (!context.mounted) return false;
    final name = await askName(context);
    if (name == null || name.trim().isEmpty) return false;
    await setName(name);
    return true;
  }

  Future<String?> askName(BuildContext context, {String? initial}) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Como você quer aparecer?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu nome aparece para os outros nas playlists publicadas e na sala ao vivo.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Seu nome',
                hintText: 'Ex.: Lucas (violão)',
              ),
              onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  static String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
