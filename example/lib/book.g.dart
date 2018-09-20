// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) {
  return Book()
    ..title = json['title'] as String
    ..genre = json['genre'] as String
    ..publishedYear = json['publishedYear'] as int
    ..publisher = json['publisher'] == null
        ? null
        : Publisher.fromJson(json['publisher'] as Map<String, dynamic>);
}

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
      'title': instance.title,
      'genre': instance.genre,
      'publishedYear': instance.publishedYear,
      'publisher': instance.publisher
    };
