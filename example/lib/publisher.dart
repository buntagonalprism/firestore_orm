import 'package:firestore_orm/firestore_orm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'publisher.fs.dart';

part 'publisher.g.dart';

@JsonSerializable()
@FirestoreObject()
class Publisher extends Object
    with _$PublisherFirestoreMixin {

  Publisher();

  String name;
  String address;
  String website;
  String phoneNumber;
  
  factory Publisher.fromJson(Map<String, dynamic> json) => _$PublisherFromJson(json);

}