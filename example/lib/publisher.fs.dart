// Generated Intl message definition file. Do not edit

// **************************************************************************
// Firestore ORM Generator
// **************************************************************************

part of 'publisher.dart';

final _oneToOneFields = {};

final _oneToManyFields = {};

class PublisherFields {
  static const NAME = 'name';
  static const ADDRESS = 'address';
  static const WEBSITE = 'website';
  static const PHONE_NUMBER = 'phoneNumber';
}

abstract class _$PublisherFirestoreMixin {
  // Outputs a deeply-encoded map of object values suitable for insertion into Firestore
  Map<String, dynamic> toFirestore() =>
      deepToJson(this.toJson(), _oneToOneFields, _oneToManyFields);

  // Outputs a json structure suitable for use with dart:convert json.encode for converting to a
  // string. Not suitable for insert into Firestore when the model contains nested objects
  Map<String, dynamic> toJson() => _$PublisherToJson(this);
}
