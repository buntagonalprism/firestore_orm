part of firestore_orm;

typedef JsonParser<T> = T Function(Map<String, dynamic> json);

/// URI encodings specifically for the characters prohibited as field paths
/// by the Flutter cloud firestore plugin. These characters are actually allowed
/// in Firestore, they just need suitable backtick escaping, however the Flutter
/// plugin does not currently support the escaping. 
final characterEncodings = {
  '/': '%2F',
  '[': '%5B',
  ']': '%5D',
  '.': '%2E',
  '*': '%2A',
  '~': '%7E',
};

void firestoreFieldPathUriEncoder(Map<String, dynamic> data) {
  if (data != null) {
    final keys = data.keys.toList();
    for (String key in keys) {
      String encoded = key;
      for (String character in characterEncodings.keys) {
        final encodedCharacter = characterEncodings[character];
        encoded = encoded.replaceAll(character, encodedCharacter);
      }
      if (encoded != key) {
        data[encoded] = data[key];
        data.remove(key);
      }
    }
  }
}

void firestoreFieldPathUriDecoder(Map<String, dynamic> json) {
    if (json != null) {
    final keys = json.keys.toList();
    for (String key in keys) {
      String decoded = key;
      for (String character in characterEncodings.keys) {
        final encodedCharacter = characterEncodings[character];
        decoded = decoded.replaceAll(encodedCharacter, character);
      }
      if (decoded != key) {
        json[decoded] = json[key];
        json.remove(key);
      }
    }
  }
}

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
