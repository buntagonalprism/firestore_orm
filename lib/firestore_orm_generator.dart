library firestore_orm;

import 'dart:async';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

final _documentAnnotation = "FirestoreDocument";
final _objectAnnotation = "FirestoreObject";
final _ignoreAnnotation = "FsIgnore";
final _timestampAnnotation = "FbTimestamp";


/// Generates db classes for use with SQFlite
class FirestoreOrmGenerator extends Generator {
  const FirestoreOrmGenerator();

  @override
  Future<String> generate(LibraryReader library, _) async {
    var output = new StringBuffer();
    for (ClassElement classElement
    in library.allElements.where((e) => e is ClassElement)) {

      final libraryName = library.element.location.toString().split('/').last;

      final classNode = classElement.computeNode();

      // Skip non-class declarations like Enums (which are still class elements)
      if (classNode is ClassDeclaration) {
        final annotations =
        classNode.metadata.map((annotation) => annotation.name.toString());

        // Must have table annotation
        if (annotations.contains(_documentAnnotation) || annotations.contains(_objectAnnotation)) {
          String modelName = classElement.name.toString();

          final includedFields = new List<String>();
          final ignoredFields = new List<String>();
          final oneToOneFields = new Map<String, String>();
          final oneToManyFields = new Map<String, String>();
          String timestampField;

          // Process strings defined as property getter functions
          for (FieldElement fieldElem in classElement.fields) {
            // Skip immutable fields
            if(fieldElem.isStatic || fieldElem.isFinal || fieldElem.isConst) {
              continue;
            }
            String fieldName = fieldElem.name.toString();

            // Get annotation
            final propAnnotations =
            fieldElem.metadata.map((a) => a.element.enclosingElement.name.toString());


            // Skip ignored fields
            if (propAnnotations.contains(_ignoreAnnotation)) {
              ignoredFields.add(fieldName);
              continue;
            }

            // Determine one to many fields in the document
            final fieldType = fieldElem.type;
            final fieldTypeAnnotations = fieldType.element.metadata.map((a) => a.element.enclosingElement.name.toString());

            if (fieldTypeAnnotations.contains(_objectAnnotation)) {
              oneToOneFields[fieldName] = fieldType.displayName;
            }
            else if (fieldType is InterfaceType && fieldType.name == "List") {
              if (fieldType.typeArguments.length == 1) {
                final listType = fieldType.typeArguments[0];
                String listTargetName = listType.displayName;
                final typeAnnotations = listType.element.metadata.map((a) => a.element.enclosingElement.name.toString());
                if (typeAnnotations.contains(_objectAnnotation)) {
                  oneToManyFields[fieldName] = listTargetName;
                }
              }
            }



            // Capture a timestamp field
            if (propAnnotations.contains(_timestampAnnotation)) {
              timestampField = fieldName;
            }

            // Add to list of included fields
            includedFields.add(fieldName);

          }
          output.writeln("part of '$libraryName';");
          output.writeln();
          printOneToOneFields(output, oneToOneFields);
          printOneToManyFields(output, oneToManyFields);
          printFieldsClass(output, includedFields, modelName);
          printClassAndFunctions(output, modelName, annotations.contains(_documentAnnotation));
        }
      }
    }

    return output.toString();
  }


  void printOneToOneFields(StringBuffer output, Map<String, String> oneToOneFields) {
    output.writeln("final _oneToOneFields = <String, Function>{");

    oneToOneFields.forEach((field, target) {
      output.writeln("'$field' : (obj) => (obj as $target).toFirestore(),");
    });

    output.writeln("};");
    output.writeln();
  }

  void printOneToManyFields(StringBuffer output, Map<String, String> oneToManyFields) {
    output.writeln("final _oneToManyFields = <String, Function>{");

    oneToManyFields.forEach((field, target) {
      output.writeln("'$field' : (obj) => (obj as $target).toFirestore(),");
    });
    
    output.writeln("};");
    output.writeln();
  }

  void printFieldsClass(StringBuffer output, List<String> fieldNames, String modelName) {
    output.writeln("class ${modelName}Fields {");
    for (var field in fieldNames) {
      output.writeln("  static const ${toUpperUnderscores(field)} = '$field';");
    }
    output.writeln("}");
    output.writeln();
  }

  void printClassAndFunctions(StringBuffer output, String modelName, bool isDocument) {
    output.writeln("abstract class _\$${modelName}FirestoreMixin {");
    output.writeln("");
    if (isDocument) {
      output.writeln("  @JsonKey(ignore: true)");
      output.writeln("  String documentId;");
      output.writeln("");
      output.writeln("  @JsonKey(ignore: true)");
      output.writeln("  String documentPath;");
      output.writeln("");
    }
    output.writeln("  // Outputs a deeply-encoded map of object values suitable for insertion into Firestore");
    output.writeln("  Map<String, dynamic> toFirestore() => deepToJson(this.toJson(), _oneToOneFields, _oneToManyFields);");
    output.writeln("");
    output.writeln("");
    output.writeln("  // Outputs a json structure suitable for use with dart:convert json.encode for converting to a");
    output.writeln("  // string. Not suitable for insert into Firestore when the model contains nested objects");
    output.writeln("  Map<String, dynamic> toJson() => _\$${modelName}ToJson(this);");
    output.writeln("");
    output.writeln("}");
    output.writeln();
    if (isDocument) {
      output.writeln("$modelName _\$${modelName}FromFirestore(DocumentSnapshot doc) {");
      output.writeln("  final json = firestoreToJson(doc.data);");
      output.writeln("  final output = $modelName.fromJson(json);");
      output.writeln("  output.documentId = doc.documentID;");
      output.writeln("  output.documentPath = doc.reference.path;");
      output.writeln("  return output;");
      output.writeln("}");
      output.writeln();
    }
  }

  String toUpperUnderscores(String input) {
    return input.replaceAllMapped(new RegExp("([a-z])([A-Z])"), (match) {
      return '${match.group(1)}_${match.group(2)}';
    }).toUpperCase();
  }

  @override
  String toString() => 'Firestore ORM Generator';
}
