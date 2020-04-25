import 'package:example/publisher.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

@JsonSerializable()
class Book  {

  Book();

  String title;
  String genre;
  int publishedYear;
  Publisher publisher;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
  Map<String, dynamic> toJson() => _$BookToJson(this);
}