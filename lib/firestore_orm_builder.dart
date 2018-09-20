

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'package:firestore_orm/firestore_orm_generator.dart';


const header = "// Generated Intl message definition file. Do not edit";

Builder firestoreOrmBuilder(BuilderOptions options) {
  return new LibraryBuilder(new FirestoreOrmGenerator(), generatedExtension: ".fs.dart", header: header);
}