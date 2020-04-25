part of firestore_orm;

/// Implement this class to automatically have the path and document Id populated when
/// using [parseSnapshots] in [DocumentReference] or [Query]
abstract class FirestoreDocument {
  String get path;
  String get documentId;
}

class DocumentSnapshot {
  final fs.DocumentSnapshot snapshot;

  Map<String, dynamic> _data;
  DocumentSnapshot(this.snapshot) {
    if (snapshot.data != null) {
      _data = _firestoreToJson(snapshot.data);
    }
  }

  Map<String, dynamic> get data => _data;

  String get documentID => snapshot.documentID;
}

class DocumentReference {
  final fs.DocumentReference _reference;

  DocumentReference(this._reference);

  /// The path of the collection which contains this document. 
  String get path => _reference.path;

  /// Firestore ID of the document
  String get documentID => _reference.documentID;

  /// Always returns a document snapshot even if the document does not yet exist. Check data = null
  /// to determine if a document does not exist in Firestore
  Future<DocumentSnapshot> get() async => DocumentSnapshot(await _reference.get());

  /// Get the stream of document update events from Firestore. The Data stream is cached by 
  /// default, so if this document has been accessed in the past, the last-delivered value
  /// will be available immediately
  DataStream<DocumentSnapshot> snapshots() => _getSnapshots();

  /// Parse the data in the firestore document into an object. 
  DataStream<T> parseSnapshots<T>(JsonParser<T> parser) => _parseSnapshots(parser);

  /// Set data on this document by serializing the values from an object. The object must have a
  /// method called 'toJson' which returns a Map<String, dynamic> containing the data. All fields
  /// of the object will be updated. To update only specific fields in the document, use [setValues]
  Future setData(dynamic data, {bool merge = false}) {
    return _reference.setData(_objectToFirestore(data), merge: merge);
  }

  /// Directly set the values of fields on this document. Allows individual field updates without
  /// having to update the entire object using [setData]
  Future setValues(Map<String, dynamic> values, {bool merge = false}) {
    return _reference.setData(_valueToFirestore(values), merge: merge);
  }

  DataStream<DocumentSnapshot> _getSnapshots() {
    final collectionPath = _reference.parent().path;
    final cachedCollection = _FirestoreCache.getCollection(collectionPath);
    final cachedDoc = cachedCollection.getDocument(documentID);
    if (cachedDoc.raw == null) {
      final stream = _reference.snapshots().asyncMap((s) async {
        final updatedDoc = DocumentSnapshot(s);
        if (cachedDoc.raw.value != null) {
          final bool contentsSame =
              DeepCollectionEquality().equals(updatedDoc.data, cachedDoc.raw.value.data);
          if (contentsSame) {
            return null;
          }
        }
        return updatedDoc;
      }).where((doc) {
        return doc != null;
      });
      cachedDoc.raw = DataStream.of(stream);
    }
    return cachedDoc.raw;
  }

  DataStream<T> _parseSnapshots<T>(JsonParser<T> parser) {
    final DataStream<DocumentSnapshot> raw = _getSnapshots();

    final collectionPath = _reference.parent().path;
    final cachedCollection = _FirestoreCache.getCollection(collectionPath);
    final cachedDoc = cachedCollection.getDocument(documentID);
    DataStream<T> parsed = cachedDoc.getParsedStream(parser);
    if (parsed == null) {
      parsed = raw.map((d) {
        if (d.data != null) {
          if (_FirestoreCache.isFirestoreDocumentType(d, parser)) {
            d.data['path'] = collectionPath;
            d.data['documentId'] = d.documentID;
          }
          final parsed = parser(d.data);
          return parsed;
        } else {
          return null;
        }
      });
      cachedDoc.addParsedStream(parser, parsed);
    }
    return cachedDoc.getParsedStream(parser);
  }
}
