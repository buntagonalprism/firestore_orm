import 'package:firestore_orm/firestore_orm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("First test", () {
    expect(MyDoc is FirestoreDocument, isTrue);
  });
}

class MyDoc implements FirestoreDocument {
  @override
  final String documentId = '1';

  @override
  final String path = '2';
}

