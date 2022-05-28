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
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['number'] = number;
    _data['name'] = name;
    _data['text'] = text;
    return _data;
  }
}
