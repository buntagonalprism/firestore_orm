// Generated Intl message definition file. Do not edit

// **************************************************************************
// Firestore ORM Generator
// **************************************************************************

part of 'author.dart';

final _oneToOneFields = {
  'firstBook': (obj) => (obj as Book).toFirestore(),
};

final _oneToManyFields = {
  'books': (obj) => (obj as Book).toFirestore(),
};

class AuthorFields {
  static const NAME = 'name';
  static const AGE = 'age';
  static const NET_WORTH = 'netWorth';
  static const FIRST_BOOK = 'firstBook';
  static const BOOKS = 'books';
}

abstract class _$AuthorFirestoreMixin {
  @JsonKey(ignore: true)
  String documentId;

  @JsonKey(ignore: true)
  String documentPath;

  // Outputs a deeply-encoded map of object values suitable for insertion into Firestore
  Map<String, dynamic> toFirestore() =>
      deepToJson(this.toJson(), _oneToOneFields, _oneToManyFields);

  // Outputs a json structure suitable for use with dart:convert json.encode for converting to a
  // string. Not suitable for insert into Firestore when the model cotnains nested objects
  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

Author _$AuthorFromFirestore(DocumentSnapshot doc) {
  final json = firestoreToJson(doc.data);
  final output = Author.fromJson(json);
  output.documentId = doc.documentID;
  output.documentPath = doc.reference.path;
  return output;
}
