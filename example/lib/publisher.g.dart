// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publisher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Publisher _$PublisherFromJson(Map<String, dynamic> json) {
  return Publisher()
    ..name = json['name'] as String
    ..address = json['address'] as String
    ..website = json['website'] as String
    ..phoneNumber = json['phoneNumber'] as String;
}

Map<String, dynamic> _$PublisherToJson(Publisher instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'website': instance.website,
      'phoneNumber': instance.phoneNumber
    };
