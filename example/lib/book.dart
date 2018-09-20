import 'package:example/publisher.dart';
import 'package:firestore_orm/firestore_orm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book.fs.dart';

part 'book.g.dart';

@JsonSerializable()
@FirestoreObject()
class Book extends Object
    with _$BookFirestoreMixin {

  Book();

  String title;
  String genre;
  int publishedYear;
  Publisher publisher;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

}