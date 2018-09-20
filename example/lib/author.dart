import 'package:example/book.dart';
import 'package:firestore_orm/firestore_orm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'author.fs.dart';

part 'author.g.dart';

@JsonSerializable()
@FirestoreDocument("/authors")
class Author extends Object
    with _$AuthorFirestoreMixin {

  Author(); 
  
  String name;
  List<String> aliases;
  int age;
  double netWorth;
  Book firstBook;
  List<Book> books;

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  factory Author.fromFirestore(DocumentSnapshot doc) => _$AuthorFromFirestore(doc);

}