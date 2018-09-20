

class FirestoreDocument {
  final String path;
  const FirestoreDocument(this.path);
}

class FirestoreObject {
  const FirestoreObject();
}

class FsIgnore {
  const FsIgnore();
}

/// Annotate any single 'int' data type column in a model to indicate that it should be updated with
/// a UNIX millisecond timestamp (UTC time) every time the model is saved to the database. Both
/// insert and update operations will be affected.
class FsTimestamp {
  const FsTimestamp();
}

/// Annotate any single 'int' data type column in a model to indicate it should be set with a UNIX
/// millisecond timestamp (UTC time) when the model is created
class FsCreateTime {
  const FsCreateTime();
}

/// Recursively maps firestore data, which is returned as Map<dynamic, dynamic> to the format
/// expected by JSON Serializable, which is Map<String, dynamic>
Map<String, dynamic> firestoreToJson(Map<dynamic, dynamic> input) {
  final output = Map<String, dynamic>();
  for (var key in input.keys) {
    var value = input[key];
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        value[i] = firestoreToJson(value[i]);
      }
    } else if (value is Map) {
      value = firestoreToJson(value);
    }
    output[key.toString()] = value;
  }
  return output;
}

Map<String, dynamic> deepToJson(Map<String, dynamic> json, Map<String, Function> oneToOneFields, Map<String, Function> oneToManyFields) {
  oneToManyFields.forEach((field, serializer) {
    if (json[field] != null) {
      for (var i = 0; i < (json[field] as List).length; i++) {
        json[field][i] = serializer(json[field][i]);
      }
    } else {
      json[field] = List<Map<String, dynamic>>();
    }
  });
  oneToOneFields.forEach((field, serializer) {
    if (json[field] != null) {
      json[field] = serializer(json[field]);
    }
  });
  return json;
}