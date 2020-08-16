part of firestore_orm;

class Query  {
  /// The inner query object from the cloud_firestore package
  final fs.Query query;

  /// Set of all arguments used to build this query
  final Map<String, dynamic> args;

  /// The collection this query is against
  final CollectionReference reference;

  Query(this.query, this.args, this.reference);

  Query where(
    String field, {
    dynamic isEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    bool isNull,
  }) =>
      Query(
          query.where(
            field,
            isEqualTo: isEqualTo,
            isLessThan: isLessThan,
            isLessThanOrEqualTo: isLessThanOrEqualTo,
            isGreaterThan: isGreaterThan,
            isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
            arrayContains: arrayContains,
            isNull: isNull,
          ),
          this.args
            ..['where:$field'] = {
              'isEqualTo': isEqualTo,
              'isLessThan': isLessThan,
              'isLessThanOrEqualTo': isLessThanOrEqualTo,
              'isGreaterThan': isGreaterThan,
              'isGreaterThanOrEqualTo': isGreaterThanOrEqualTo,
              'arrayContains': arrayContains,
              'isNull': isNull,
            }, this.reference);

  Query orderBy(String field, {bool descending = false}) => Query(
      query.orderBy(field, descending: descending), this.args..['orderby'] = '$field:$descending', this.reference);

  Query startAfter(List<dynamic> values) =>
      Query(query.startAfter(values), this.args..['startAfter'] = values, this.reference);

  Query startAt(List<dynamic> values) =>
      Query(query.startAt(values), this.args..['startAt'] = values, this.reference);

  Query endAt(List<dynamic> values) =>
      Query(query.endAt(values), this.args..['endAt'] = values, this.reference);

  Query endBefore(List<dynamic> values) =>
      Query(query.endBefore(values), this.args..['endBefore'] = values, this.reference);

  Query limit(int length) => Query(query.limit(length), this.args..['length'] = length, this.reference);

  /// When [useCache] is true, every query has its arguments and Firestore results stored in 
  /// memory, so that the results are synchronously available the next time they are needed. This 
  /// improves load performance in many situations. However when running many dynamic queries
  /// against a large document collection (such as user free-text searches) this could result
  /// in high memory usage as every query and their results are cached. [getDocuments] may be
  /// a better choice for that use case, or set useCache to false. 
  DataStream<QuerySnapshot> snapshots({bool useCache = true}) => _getSnapshots(useCache: useCache);

  /// Parses the results from a [QuerySnapshot] into a list of objects using a JSON parsing 
  /// function. See comments on [snapshots] for a description of [useCache]
  DataStream<Iterable<T>> parseSnapshots<T>(JsonParser<T> parser, {bool useCache = true}) => _parseSnapshots(parser, useCache: useCache);

  /// Retrieve the latest set of documents that match this query from Firestore. Always makes 
  /// a network request, even if the documents have been retrieved recently. 
  Future<QuerySnapshot> getDocuments() async => QuerySnapshot(await query.get(), reference.path);

  // Build a JSON string summarising the arguments applied to this query. Allows different query
  // objects to be compared. This method will always return the same string for any query that
  // will produce the same results, no matter the order that query arguments were applied.
  String getArgsSummary() {
    final sortedKeys = args.keys.toList()..sort();
    final queryArgs = List<dynamic>();
    for (String key in sortedKeys) {
      queryArgs.add(key);
      queryArgs.add(args[key]);
    }
    return json.encode(queryArgs);
  }

  DataStream<QuerySnapshot> _getSnapshots({bool useCache = true}) {
    final collectionPath = reference.path;
    if (useCache) {
      final cachedCollection = _FirestoreCache.getCollection(collectionPath);
      final cachedQuery = cachedCollection.getQuery(this);
      if (cachedQuery.raw == null) {
        final stream = query.snapshots().asyncMap((s) async {
          final updatedQuery = QuerySnapshot(s, collectionPath);

          // If we have a cached value, and if the incoming snapshot does not have document changes
          // then we perform a diff check to decide whether to emit or not.
          if (cachedQuery.raw.value != null && s.docs.length == s.docChanges.length) {
            List<dynamic> cached = cachedQuery.raw.value.documents.map((d) => d.data).toList();
            List<dynamic> updated = updatedQuery.documents.map((d) => d.data).toList();
            if (cached.length == updated.length) {
              // Synchronous diff check for small collections
              if (cached.length < 50) {
                final bool contentsSame = DeepCollectionEquality().equals(cached, updated);
                if (contentsSame) {
                  return null;
                }
              }
              // Background thread diff check for large collections
              else {
                final bool contentsSame = await listsAreSame(cached, updated);
                if (contentsSame) {
                  return null;
                }
              }
            }
          }
          return updatedQuery;
        }).where((doc) {
          return doc != null;
        });
        cachedQuery.raw = DataStream.of(stream);
      }
      return cachedQuery.raw;
    } else {
      return DataStream.of(query.snapshots().map((s) => QuerySnapshot(s, collectionPath)));
    }
  }

  DataStream<Iterable<T>> _parseSnapshots<T>(JsonParser<T> parser, {bool useCache = true}) {
    final DataStream<QuerySnapshot> raw = _getSnapshots(useCache: useCache);
    final collectionPath = reference.path;

    if (useCache) {
      final cachedCollection = _FirestoreCache.getCollection(collectionPath);
      final cachedQuery = cachedCollection.getQuery(this);

      DataStream<Iterable<T>> parsed = cachedQuery.getParsedStream(parser);
      if (parsed == null) {
        parsed = raw.map(_buildQuerySnapshotParser(collectionPath, parser));
        cachedQuery.addParsedStream(parser, parsed);
      }
      return cachedQuery.getParsedStream(parser);
    } else {
      return raw.map(_buildQuerySnapshotParser(collectionPath, parser));
    }
  }
}

class CollectionReference extends Query  {
  final fs.CollectionReference collection;

  CollectionReference(this.collection) : super(collection, {}, CollectionReference(collection));

  String get id => collection.id;

  String get path => collection.path;

  DocumentReference document([String path]) => DocumentReference(collection.doc(path));

}

class QuerySnapshot {
  final fs.QuerySnapshot querySnapshot;
  final String collectionPath;

  QuerySnapshot(this.querySnapshot, this.collectionPath);

  List<DocumentSnapshot> get documents =>
      querySnapshot.docs.map((d) => DocumentSnapshot(d)).toList();

  List<T> parseDocuments<T>(JsonParser<T> parser) {
    return _buildQuerySnapshotParser(collectionPath, parser)(this);
  }
}

List<T> Function(QuerySnapshot snapshot) _buildQuerySnapshotParser<T>(String collectionPath, JsonParser<T> parser) {
  return (QuerySnapshot snapshot) => snapshot.documents.map((d) => _parseSnapshot(d, collectionPath, parser)).toList();
}