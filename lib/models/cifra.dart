class Cifra {
  final int id;
  final String title;
  final String createdAt;
  final String updatedAt;
  final CifraFile? file;
  final String? localFilePath;

  /// 'pdf' (painel), 'image' (foto enviada pelo app) ou 'text' (digitada).
  final String? _kind;

  /// Quem enviou (só nas cifras enviadas pelo app).
  final String? authorName;

  /// Tom original informado por quem enviou (ex.: G).
  final String? tone;

  Cifra({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.file,
    this.localFilePath,
    String? kind,
    this.authorName,
    this.tone,
  }) : _kind = kind;

  /// Tipo da cifra; se não veio, deduz pela extensão do arquivo.
  String get kind {
    if (_kind != null && _kind.isNotEmpty) return _kind;
    final path = (localFilePath ?? file?.filename ?? '').toLowerCase();
    if (path.endsWith('.txt')) return 'text';
    if (path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp')) {
      return 'image';
    }
    return 'pdf';
  }

  bool get isCommunity => authorName != null && authorName!.isNotEmpty;
  bool get isDownloaded => localFilePath != null;

  factory Cifra.fromJson(Map<String, dynamic> json) {
    return Cifra(
      id: json['id'],
      title: json['title'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      file: json['file'] != null ? CifraFile.fromJson(json['file']) : null,
      kind: json['kind'] as String?,
      authorName: json['author_name'] as String?,
      tone: json['tone'] as String?,
    );
  }

  /// Linha do SQLite local.
  factory Cifra.fromDb(Map<String, dynamic> row) {
    return Cifra(
      id: row['id'] as int,
      title: row['title'] as String,
      createdAt: row['created_at'] as String? ?? '',
      updatedAt: row['updated_at'] as String? ?? '',
      localFilePath: row['local_file_path'] as String?,
      kind: row['kind'] as String?,
      authorName: row['author_name'] as String?,
      tone: row['tone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'local_file_path': localFilePath,
      'kind': _kind,
      'author_name': authorName,
      'tone': tone,
    };
  }

  Cifra copyWith({String? title, String? tone, String? localFilePath}) {
    return Cifra(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: DateTime.now().toIso8601String(),
      file: file,
      localFilePath: localFilePath ?? this.localFilePath,
      kind: _kind,
      authorName: authorName,
      tone: tone ?? this.tone,
    );
  }
}

class CifraFile {
  final int id;
  final String filename;
  final String url;
  final int size;

  CifraFile({
    required this.id,
    required this.filename,
    required this.url,
    required this.size,
  });

  factory CifraFile.fromJson(Map<String, dynamic> json) {
    return CifraFile(
      id: json['id'],
      filename: json['title'] ?? json['original_title'] ?? 'arquivo.pdf',
      url: json['url'],
      size: json['size'],
    );
  }
}