part of firestore_orm;



class FirestoreOrm {
  static FirestoreOrm _instance;
  static FirestoreOrm get instance => _instance;

  static fs.FirebaseFirestore _fs;

  static init({FirebaseApp firebaseApp}) {
    if (firebaseApp != null) {
    _fs = fs.FirebaseFirestore.instanceFor(app: firebaseApp);
    } else {
      _fs = fs.FirebaseFirestore.instance;
    }
    _instance = FirestoreOrm();
  }

  CollectionReference collection(String path) => CollectionReference(_fs.collection(path));

  DocumentReference document(String path) => DocumentReference(_fs.doc(path));

  Future runTransaction(Future Function(Transaction tx) handler) {
    return _fs.runTransaction((transaction) => handler(Transaction(transaction)));
  }

  void clearCache() {
    _FirestoreCache.clear();
  }
}
