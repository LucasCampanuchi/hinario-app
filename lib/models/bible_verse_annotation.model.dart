class BibleVerseAnnotation {
  final int verseId;
  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final bool favorite;
  final int? colorValue;
  final String? note;

  const BibleVerseAnnotation({
    required this.verseId,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.favorite = false,
    this.colorValue,
    this.note,
  });

  bool get hasMarking =>
      colorValue != null || (note?.trim().isNotEmpty ?? false);

  BibleVerseAnnotation copyWith({
    bool? favorite,
    int? colorValue,
    bool clearColor = false,
    String? note,
    bool clearNote = false,
  }) => BibleVerseAnnotation(
    verseId: verseId,
    bookId: bookId,
    bookName: bookName,
    chapter: chapter,
    verse: verse,
    text: text,
    favorite: favorite ?? this.favorite,
    colorValue: clearColor ? null : (colorValue ?? this.colorValue),
    note: clearNote ? null : (note ?? this.note),
  );

  factory BibleVerseAnnotation.fromJson(Map<String, dynamic> json) =>
      BibleVerseAnnotation(
        verseId: json['verse_id'] as int,
        bookId: json['book_id'] as int,
        bookName: json['book_name'] as String,
        chapter: json['chapter'] as int,
        verse: json['verse'] as int,
        text: json['text'] as String,
        favorite: json['favorite'] as bool? ?? false,
        colorValue: json['color_value'] as int?,
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'verse_id': verseId,
    'book_id': bookId,
    'book_name': bookName,
    'chapter': chapter,
    'verse': verse,
    'text': text,
    'favorite': favorite,
    'color_value': colorValue,
    'note': note,
  };
}
