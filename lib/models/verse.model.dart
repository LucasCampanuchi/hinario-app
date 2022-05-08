class VerseModel {
  int? id;
  int? bookId;
  int? chapter;
  int? verse;
  String? text;

  VerseModel({this.id, this.bookId, this.chapter, this.verse, this.text});

  VerseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookId = json['book_id'];
    chapter = json['chapter'];
    verse = json['verse'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['book_id'] = bookId;
    data['chapter'] = chapter;
    data['verse'] = verse;
    data['text'] = text;
    return data;
  }
}
