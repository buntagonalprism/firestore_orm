import 'package:example/book.dart';
import 'package:firestore_orm/firestore_orm.dart';
import 'package:json_annotation/json_annotation.dart';


part 'author.g.dart';

@JsonSerializable()
class Author extends FirestoreDocument {

  Author(); 

  String path;
  String documentId;
  String name;
  List<String> aliases;
  int age;
  double netWorth;
  Book firstBook;
  List<Book> books;
  

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}