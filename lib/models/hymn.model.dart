class HymnModel {
  HymnModel({
    required this.id,
    required this.number,
    required this.name,
    required this.text,
  });
  late final int id;
  late final String number;
  late final String name;
  late final String text;

  HymnModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    name = json['name'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['number'] = number;
    data['name'] = name;
    data['text'] = text;
    return data;
  }
}
