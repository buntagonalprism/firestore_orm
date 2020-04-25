part of firestore_orm;

// Implement this class to automatically have the path and document Id populated when
// using [parseSnapshots]
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

  String get path => _reference.path;

  String get documentID => _reference.documentID;

  Future<DocumentSnapshot> get() async => DocumentSnapshot(await _reference.get());

  DataStream<DocumentSnapshot> snapshots() => _getSnapshots();

  DataStream<T> parseSnapshots<T>(JsonParser<T> parser) => _parseSnapshots(parser);

  Future setData(dynamic data, {bool merge = false}) {
    return _reference.setData(_objectToFirestore(data), merge: merge);
  }

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
