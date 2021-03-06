part of firestore_orm;



class FirestoreOrm {
  static FirestoreOrm _instance;
  static FirestoreOrm get instance => _instance;

  static fs.Firestore _fs;

  static init({FirebaseApp firebaseApp}) {
    _fs = fs.Firestore(app: firebaseApp);
    _instance = FirestoreOrm();
  }

  CollectionReference collection(String path) => CollectionReference(_fs.collection(path));

  DocumentReference document(String path) => DocumentReference(_fs.document(path));

  Future runTransaction(Future Function(Transaction tx) handler) {
    return _fs.runTransaction((transaction) => handler(Transaction(transaction)));
  }

  void clearCache() {
    _FirestoreCache.clear();
  }
}
