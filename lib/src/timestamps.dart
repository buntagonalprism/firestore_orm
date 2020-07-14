import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Decorate a Firestore model class with this class to automatically convert
/// Firestore [Timestamp] objects into standard dart [DateTime] objects
class FirestoreTimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const FirestoreTimestampConverter();

  @override
  DateTime fromJson(Timestamp json) {
    return json?.toDate() ?? null;
  }

  @override
  Timestamp toJson(DateTime date) => date != null ? Timestamp.fromDate(date) : null;
}