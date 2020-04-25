part of firestore_orm;

/// Manages caching for the [firestore_orm] package, tracking all previous queries and 
/// documents in memory. This may cause memory issues in the case of very large documents
/// accessed with multiple different queries. 
class _FirestoreCache {
  static final Map<String, _CollectionCache> collections = <String, _CollectionCache>{};
  static final Map<Type, bool> firestoreDocTypes = <Type, bool>{};

  static _CollectionCache getCollection(String collectionPath) {
    if (!collections.containsKey(collectionPath)) {
      collections[collectionPath] = _CollectionCache();
    }
    return collections[collectionPath];
  }

  /// Clear the firestore cache of all data.
  static void clear() {
    collections.clear();
  }

  /// Check whether the result of parsing the data of a document snapshot would be
  /// an implementation of [FirestoreDocument]. Used to determine whether to add 
  /// firestore metadata into the JSON data before it is parsed. 
  static bool isFirestoreDocumentType<T>(DocumentSnapshot doc, JsonParser<T> parser) {
    if (!firestoreDocTypes.containsKey(T)) {
      if (doc.data != null) {
        final parsed = parser(doc.data);
        firestoreDocTypes[T] = (parsed is FirestoreDocument);
      } else {
        // If the document data is null, it cannot be parsed so by default the result
        // will not be a FirestoreDocument
        return false;
      }
    }
    return firestoreDocTypes[T];
  }

}

class _CollectionCache {
  final Map<String, _DocumentCache> documents = <String, _DocumentCache>{};
  final Map<String, _QueryCache> queries = <String, _QueryCache>{};

  _DocumentCache getDocument(String id) {
    if (documents[id] == null) {
      documents[id] = _DocumentCache();
    }
    return documents[id];
  }

  _QueryCache getQuery(Query query) {
    final String queryId = query.getArgsSummary();
    if (queries[queryId] == null) {
      queries[queryId] = _QueryCache();
    }
    return queries[queryId];
  }
}

class _DocumentCache {
  DataStream<DocumentSnapshot> raw;
  List<_ParsedDocumentCache> parsed = <_ParsedDocumentCache>[];

  DataStream<T> getParsedStream<T>(JsonParser<T> parser) {
    for (_ParsedDocumentCache stream in parsed) {
      if (stream.parser == parser) {
        return stream.parsed;
      }
    }
    return null;
  }

  void addParsedStream<T>(JsonParser<T> parser, DataStream<T> parsedStream) {
    parsed.add(_ParsedDocumentCache(parser, parsedStream));
  }
}

class _ParsedDocumentCache<T> {
  final JsonParser<T> parser;
  final DataStream<T> parsed;

  _ParsedDocumentCache(this.parser, this.parsed);
}

class _QueryCache {
  DataStream<QuerySnapshot> raw;
  List<_ParsedQueryCache> parsed = <_ParsedQueryCache>[];

  DataStream<Iterable<T>> getParsedStream<T>(JsonParser<T> parser) {
    for (_ParsedQueryCache stream in parsed) {
      if (stream.parser == parser) {
        return stream.parsed;
      }
    }
    return null;
  }

  void addParsedStream<T>(JsonParser<T> parser, DataStream<Iterable<T>> parsedStream) {
    parsed.add(_ParsedQueryCache(parser, parsedStream));
  }
}

class _ParsedQueryCache<T> {
  final JsonParser<T> parser;
  final DataStream<Iterable<T>> parsed;

  _ParsedQueryCache(this.parser, this.parsed);
}

Future<bool> listsAreSame(List<dynamic> source, List<dynamic> target) {
  return compute(deepListEquality, {'a': source, 'b': target});
}

bool deepListEquality(Map<String, dynamic> compare) {
  final List<dynamic> a = compare['a'];
  final List<dynamic> b = compare['b'];
  return DeepCollectionEquality().equals(a, b);
}