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
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['text'] = text;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
