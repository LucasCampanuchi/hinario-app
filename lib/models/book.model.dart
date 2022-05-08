class BookModel {
  int? id;
  int? bookReferenceId;
  int? testamentReferenceId;
  String? name;

  BookModel({
    this.id,
    this.bookReferenceId,
    this.testamentReferenceId,
    this.name,
  });

  BookModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookReferenceId = json['book_reference_id'];
    testamentReferenceId = json['testament_reference_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['book_reference_id'] = bookReferenceId;
    data['testament_reference_id'] = testamentReferenceId;
    data['name'] = name;
    return data;
  }
}
