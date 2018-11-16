// Generated Intl message definition file. Do not edit

// **************************************************************************
// Firestore ORM Generator
// **************************************************************************

part of 'book.dart';

class BookFields {
  static const TITLE = 'title';
  static const GENRE = 'genre';
  static const PUBLISHED_YEAR = 'publishedYear';
  static const PUBLISHER = 'publisher';
}

abstract class _$BookFirestoreMixin {
  // Outputs a deeply-encoded map of object values suitable for insertion into Firestore
  Map<String, dynamic> toFirestore() => deepToJson(this.toJson());

  // Outputs a json structure suitable for use with dart:convert json.encode for converting to a
  // string. Not suitable for insert into Firestore when the model contains nested objects
  Map<String, dynamic> toJson() => _$BookToJson(this);
}
