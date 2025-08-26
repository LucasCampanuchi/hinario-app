class Cifra {
  final int id;
  final String title;
  final String createdAt;
  final String updatedAt;
  final CifraFile? file;
  final String? localFilePath;

  Cifra({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.file,
    this.localFilePath,
  });

  factory Cifra.fromJson(Map<String, dynamic> json) {
    return Cifra(
      id: json['id'],
      title: json['title'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      file: json['file'] != null ? CifraFile.fromJson(json['file']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'local_file_path': localFilePath,
    };
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