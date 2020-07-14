part of firestore_orm;

typedef JsonParser<T> = T Function(Map<String, dynamic> json);

Map<String, dynamic> _firestoreToJson(Map<dynamic, dynamic> input) {
  final output = Map<String, dynamic>();
  for (var key in input.keys) {
    var value = input[key];
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        if (value[i] is Map) {
          value[i] = _firestoreToJson(value[i]);
        }
      }
    } else if (value is Map) {
      value = _firestoreToJson(value);
    }
    output[key.toString()] = value;
  }
  return output;
}

dynamic _valueToFirestore(dynamic value) {
  if (value == null) {
    return value;
  } else if ([String, int, double, DateTime, bool].contains(value.runtimeType)) {
    return value;
  } else if (value is List) {
    final outputList = List<dynamic>();
    for (dynamic listItem in value) {
      outputList.add(_valueToFirestore(listItem));
    }
    return outputList;
  } else if (value is Map) {
    final outputMap = Map<String, dynamic>();
    for (dynamic key in value.keys) {
      outputMap[key.toString()] = _valueToFirestore(value[key]);
    }
    return outputMap;
  } else {
    return _objectToFirestore(value);
  }
}

Map<String, dynamic> _objectToFirestore(dynamic object) {
  if (object == null) {
    return null;
  }
  Map<String, dynamic> mappedData;
  try {
    mappedData = object.toJson();
    if (object is FirestoreDocument) {
      mappedData.remove('path');
      mappedData.remove('documentId');
    }
  } catch (_) {
    throw "Error preparing object of type ${object.runtimeType} for saving to Firestore. Ensure this type has a toJson method.";
  }
  for (String key in mappedData.keys) {
    mappedData[key] = _valueToFirestore(mappedData[key]);
  }
  return mappedData;
}
