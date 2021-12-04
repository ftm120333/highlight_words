class Word {
  int? pageNum;
  int? verseNum;
  String? word;
  String? surahName;
  String? details;
  String? title;
  double? x;
  double? y;
  double? w;
  double? h;

  Word({this.surahName, this.word, this.pageNum,
      this.verseNum, this.title, this.details, this.x,  this.h, this.w, this.y});

  Map<String, dynamic> toMap() {
    return {
      'pageNum': surahName,
      'verseNum': verseNum,
      'word': word,
      'surahName': surahName,
      'details': details,
      'title': title,
      'x':x,
      'y': y,
      'w': w,
      'h': h,
    };
  }
}