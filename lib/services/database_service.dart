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
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        local_file_path TEXT
      )
    ''');
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
      final count = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName WHERE id = ?', [cifra.id]);
      print('[DB] Verificação: cifra ${cifra.id} existe no banco: ${count.first['count']}');
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
        orderBy: 'title ASC',
        limit: limit,
        offset: offset,
      );
      
      return List.generate(maps.length, (i) {
        return Cifra(
          id: maps[i]['id'],
          title: maps[i]['title'],
          createdAt: maps[i]['created_at'],
          updatedAt: maps[i]['updated_at'],
          localFilePath: maps[i]['local_file_path'],
        );
      });
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
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
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
}