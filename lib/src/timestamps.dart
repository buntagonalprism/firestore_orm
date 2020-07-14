part of firestore_orm;

/// Decorate a Firestore model class with this class to automatically convert
/// Firestore [Timestamp] objects into standard dart [DateTime] objects
class FirestoreTimestampConverter implements JsonConverter<DateTime, fs.Timestamp> {
  const FirestoreTimestampConverter();

  @override
  DateTime fromJson(fs.Timestamp json) {
    return json?.toDate() ?? null;
  }

  @override
  fs.Timestamp toJson(DateTime date) => date != null ? fs.Timestamp.fromDate(date) : null;
}