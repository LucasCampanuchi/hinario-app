import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cifra.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'cifras';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cifras.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        local_file_path TEXT,
        kind TEXT,
        author_name TEXT,
        tone TEXT
      )
    ''');
  }

  /// v2: cifras enviadas pelo app (foto/texto) guardam tipo, autor e tom.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN kind TEXT');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN author_name TEXT');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN tone TEXT');
    }
  }

  Future<void> deleteCifra(int id) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertCifra(Cifra cifra) async {
    try {
      final db = await database;
      final data = cifra.toJson();
      print('[DB] Inserindo cifra: ${cifra.id} - ${cifra.title}');
      print('[DB] Dados: $data');

      final result = await db.insert(
        _tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('[DB] Cifra ${cifra.id} inserida com sucesso (row: $result)');

      // Verificar se foi realmente inserida
      final count = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $_tableName WHERE id = ?', [cifra.id]);
      print(
          '[DB] Verificação: cifra ${cifra.id} existe no banco: ${count.first['count']}');
    } catch (e, stackTrace) {
      print('[DB ERROR] Erro ao inserir cifra ${cifra.id}: $e');
      print('[DB ERROR] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Cifra>> getAllCifras({int? limit, int? offset}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'id DESC',
        limit: limit,
        offset: offset,
      );

      return maps.map(Cifra.fromDb).toList();
    } catch (e, stackTrace) {
      print('[DB ERROR] Erro ao buscar cifras: $e');
      print('[DB ERROR] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateCifraFilePath(int id, String filePath) async {
    try {
      print('[DB] Atualizando caminho do arquivo para cifra $id: $filePath');
      final db = await database;
      await db.update(
        _tableName,
        {'local_file_path': filePath},
        where: 'id = ?',
        whereArgs: [id],
      );
      print('[DB] Caminho atualizado com sucesso para cifra $id');
    } catch (e, stackTrace) {
      print('[DB ERROR] Erro ao atualizar caminho da cifra $id: $e');
      print('[DB ERROR] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String?> getLastSyncDate() async {
    final db = await database;
    final result = await db.query(
      _tableName,
      columns: ['updated_at'],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first['updated_at'] as String : null;
  }

  Future<void> clearAllCifras() async {
    try {
      print('[DB] Limpando todas as cifras do banco...');
      final db = await database;
      await db.delete(_tableName);
      print('[DB] Todas as cifras foram removidas do banco');
    } catch (e, stackTrace) {
      print('[DB ERROR] Erro ao limpar cifras: $e');
      print('[DB ERROR] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<int> getCifrasCount() async {
    try {
      final db = await database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
      return result.first['count'] as int;
    } catch (e, stackTrace) {
      print('[DB ERROR] Erro ao contar cifras: $e');
      print('[DB ERROR] Stack trace: $stackTrace');
      return 0;
    }
  }

  Future<List<int>> getAllCifraIds() async {
    try {
      final db = await database;
      final result = await db.query(_tableName, columns: ['id']);
      return result.map((row) => row['id'] as int).toList();
    } catch (e, stackTrace) {
      print('[DB ERROR] Erro ao buscar IDs das cifras: $e');
      print('[DB ERROR] Stack trace: $stackTrace');
      return [];
    }
  }

  Future<List<Cifra>> searchCifras(String query) async {
    try {
      final db = await database;

      // Buscar todos os registros e filtrar no Dart
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'title ASC',
      );

      // Normalizar a query
      final normalizedQuery = _normalizeText(query.toLowerCase());

      // Filtrar no Dart com normalização
      final filteredMaps = maps.where((map) {
        final title = map['title'] as String;
        final normalizedTitle = _normalizeText(title.toLowerCase());
        return normalizedTitle.contains(normalizedQuery);
      }).toList();

      print(
          '[DB] Busca por "$query" (normalizada: "$normalizedQuery") retornou ${filteredMaps.length} resultados');

      return filteredMaps.map(Cifra.fromDb).toList();
    } catch (e, stackTrace) {
      print('[DB ERROR] Erro ao buscar cifras: $e');
      print('[DB ERROR] Stack trace: $stackTrace');
      rethrow;
    }
  }

  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }
}
