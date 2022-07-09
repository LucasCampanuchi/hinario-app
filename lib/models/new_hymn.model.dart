class NewHymnModel {
  NewHymnModel({
    required this.id,
    required this.name,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
  });
  late final int id;
  late final String name;
  late final String text;
  late final String createdAt;
  late final String updatedAt;

  NewHymnModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    text = json['text'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['text'] = text;
    _data['createdAt'] = createdAt;
    _data['updatedAt'] = updatedAt;
    return _data;
  }
}
