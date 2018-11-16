// Generated Intl message definition file. Do not edit

// **************************************************************************
// Firestore ORM Generator
// **************************************************************************

part of 'author.dart';

class AuthorFields {
  static const NAME = 'name';
  static const ALIASES = 'aliases';
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

  @JsonKey(ignore: true)
  DocumentReference documentReference;

  // Outputs a deeply-encoded map of object values suitable for insertion into Firestore
  Map<String, dynamic> toFirestore() => deepToJson(this.toJson());

  // Outputs a json structure suitable for use with dart:convert json.encode for converting to a
  // string. Not suitable for insert into Firestore when the model contains nested objects
  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}

Author _$AuthorFromFirestore(DocumentSnapshot doc) {
  final json = firestoreToJson(doc.data);
  final output = Author.fromJson(json);
  output.documentId = doc.documentID;
  output.documentPath = doc.reference.path;
  output.documentReference = doc.reference;
  return output;
}
