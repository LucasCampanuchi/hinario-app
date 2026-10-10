import '../models/cifra.dart';
import 'database_service.dart';

/// Acesso rápido às cifras baixadas no aparelho, por id da API.
class CifraLookupService {
  CifraLookupService._();
  static final CifraLookupService instance = CifraLookupService._();

  final DatabaseService _db = DatabaseService();
  Map<int, Cifra>? _cache;

  Future<Map<int, Cifra>> all({bool refresh = false}) async {
    if (_cache != null && !refresh) return _cache!;
    final cifras = await _db.getAllCifras();
    _cache = {for (final c in cifras) c.id: c};
    return _cache!;
  }

  Future<Cifra?> byId(int id) async {
    final map = await all();
    final found = map[id];
    if (found != null) return found;
    // pode ter sido baixada depois do cache: tenta de novo uma vez
    return (await all(refresh: true))[id];
  }

  void invalidate() => _cache = null;
}
