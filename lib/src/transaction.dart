part of firestore_orm;

class Transaction {
  final fs.Transaction transaction;

  Transaction(this.transaction);

  /// Set data on this document by serializing the values from an object. The object must have a
  /// method called 'toJson' which returns a Map<String, dynamic> containing the data. All fields
  /// of the object will be updated. To update only specific fields in the document, use [setValues]
  /// By default replaces the entire document. Set merge = true to only update fields present in
  /// the supplied data and leave other existing document fields unchanged. 
  Future setData(DocumentReference ref, dynamic data, {bool merge = false}) {
    if (merge) {
      return transaction.update(ref._reference, _objectToFirestore(data));
    } else {
      return transaction.set(ref._reference, _objectToFirestore(data));
    }
  }

  /// Directly set the values of fields on this document. Allows individual field updates without
  /// having to update the entire object using [setData]. By default merges the supplied
  /// fields into any existing document data, leaving other fields unchanged. Set merge = false
  /// to replace the entire document data with the supplied values. 
  Future setValues(DocumentReference ref, Map<String, dynamic> values, {bool merge = true}) {
    if (merge) {
      return transaction.update(ref._reference, _valueToFirestore(values));
    } else {
      return transaction.set(ref._reference, _valueToFirestore(values));
    }
  }

  Future delete(DocumentReference ref) {
    return transaction.delete(ref._reference);
  }
}