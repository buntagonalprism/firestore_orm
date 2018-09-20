// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Author _$AuthorFromJson(Map<String, dynamic> json) {
  return Author()
    ..name = json['name'] as String
    ..aliases = (json['aliases'] as List)?.map((e) => e as String)?.toList()
    ..age = json['age'] as int
    ..netWorth = (json['netWorth'] as num)?.toDouble()
    ..firstBook = json['firstBook'] == null
        ? null
        : Book.fromJson(json['firstBook'] as Map<String, dynamic>)
    ..books = (json['books'] as List)
        ?.map(
            (e) => e == null ? null : Book.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
      'name': instance.name,
      'aliases': instance.aliases,
      'age': instance.age,
      'netWorth': instance.netWorth,
      'firstBook': instance.firstBook,
      'books': instance.books
    };
