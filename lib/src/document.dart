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

  /// The full path to this document, including its collection path and document ID. 
  String get path => _reference.path;

  /// Firestore ID of the document
  String get documentID => _reference.documentID;

  /// Always returns a document snapshot even if the document does not yet exist. Check data = null
  /// to determine if a document does not exist in Firestore
  Future<DocumentSnapshot> get() async => DocumentSnapshot(await _reference.get());

  /// Get the data of a document and parse it using the supplied data. If the document does not
  /// exist then null will be returned. 
  Future<T> parseData<T>(JsonParser<T> parser) async {
    final snapshot = await get();
    return _parseSnapshot(snapshot, _reference.parent().path, parser);
  }

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

  /// Delete this document
  Future delete() => _reference.delete();

  /// Get a sub-collection within this document by name
  CollectionReference collection(String collectionName) {
    return CollectionReference(_reference.collection(collectionName));
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
      parsed = raw.map((d) => _parseSnapshot(d, collectionPath, parser));
      cachedDoc.addParsedStream(parser, parsed);
    }
    return cachedDoc.getParsedStream(parser);
  }

  T _parseSnapshot<T>(DocumentSnapshot d, String collectionPath, JsonParser<T> parser) {
    if (d.data != null) {
      if (_FirestoreCache.isFirestoreDocumentType(d, parser)) {
        d.data['path'] = collectionPath + '/' + d.documentID;
        d.data['documentId'] = d.documentID;
      }
      final parsed = parser(d.data);
      return parsed;
    } else {
      return null;
    }
  }
}
