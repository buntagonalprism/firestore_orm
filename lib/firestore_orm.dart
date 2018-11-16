

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
        if (value[i] is Map) {
          value[i] = firestoreToJson(value[i]);
        }
      }
    } else if (value is Map) {
      value = firestoreToJson(value);
    }
    output[key.toString()] = value;
  }
  return output;
}

Map<String, dynamic> deepToJson(Map<String, dynamic> json) {

  for (var key in json.keys) {
    dynamic value = json[key];
    if (_isArray(value)) {
      json[key] = _convertListToJson(value);
    }
    else if (_isNotJsonObject(value)) {
      json[key] = _convertToJson(value);
    }
  }
  return json;
}

List<Map<String, dynamic>> _convertListToJson(List<dynamic> items) {
  final output = List<Map<String, dynamic>>();
  for (var i = 0; i < items.length; i++) {
    output.add(_convertToJson(items[i]));
  }
  return output;
}

Map<String, dynamic> _convertToJson(dynamic value) {
  if (value == null) {
    return null;
  }
  Map<String, dynamic> output;
  try {
    output = value.toJson();
  } catch (e) {
    throw "Object of type ${value.runtimeType} missing required JSON serializer. Add toJson() class method or add JsonKey(ignore: true). Object value was: ${value.toString()}";
  }
  return deepToJson(output);
}

bool _isArray(dynamic value) {
  return value is List;
}

bool _isNotJsonObject(dynamic value) {
  return ! _allowedJsonTypes.contains(value.runtimeType);
}


final List<Type> _allowedJsonTypes = [bool, int, double, String, Map, List];

