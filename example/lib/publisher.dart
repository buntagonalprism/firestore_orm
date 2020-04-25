import 'package:firestore_orm/firestore_orm.dart';
import 'package:json_annotation/json_annotation.dart';

part 'publisher.g.dart';

@JsonSerializable()
class Publisher extends FirestoreDocument {

  Publisher();

  String path;
  String documentId;
  String name;
  String address;
  String website;
  String phoneNumber;
  
  factory Publisher.fromJson(Map<String, dynamic> json) => _$PublisherFromJson(json);
  Map<String, dynamic> toJson() => _$PublisherToJson(this);

}