library intl_generator;


import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';


const _i18nPkgName = "Intl";
const _i18nFunctions = const ["message", "plural", "gender"];

String addNameAndArgs(String outputStr, String name, MethodDeclaration node, MethodInvocation expression) {
  // If the Intl.message call does not already contain a 'name' parameter, add the element name
  if (!methodInvocationContainsNamedParam(expression, "name")) {
    outputStr = outputStr.replaceAll(new RegExp("\\);"), ', name: "$name");');
  }

  // If the Intl.message does not include an 'args' parameter, add the args property
  if (!methodInvocationContainsNamedParam(expression, "args") && node.parameters != null) {
    String argsList = node.parameters.parameters.map((p) => p.identifier.toString()).join(', ');
    outputStr = outputStr.replaceAll(new RegExp("\\);"), ', args: [$argsList]);');
  }
  return outputStr;
}

String getIntlCreatorSource(Element sourceElement) {
  String name = sourceElement.displayName;
  AstNode node = sourceElement.computeNode();
  if (node is MethodDeclaration) {
    FunctionBody body = node.body;
    if (body is ExpressionFunctionBody) {
      Expression expression = body.expression;
      if (expression is MethodInvocation) {

        // This property uses an Intl function directly
        if (_i18nPkgName == expression.target.toString() &&
            _i18nFunctions.contains(expression.methodName.toString())) {
          return addNameAndArgs(node.toString(), name, node, expression);
        }

        // This property uses a thin-wrapper around an Intl function, such as the `const msg = Intl.message;` shorthand
        // Replace it with the original name
        if (expression?.staticInvokeType?.element?.enclosingElement != null &&
            _i18nPkgName == expression.staticInvokeType.element.enclosingElement.name &&
            _i18nFunctions.contains(expression.staticInvokeType.element.name)) {
          String wrapperName = expression.methodName.token.value();
          String replaceWith = _i18nPkgName + "." + expression.staticInvokeType.element.name;
          String output = node.toString().replaceFirst(new RegExp(wrapperName), replaceWith);
          return addNameAndArgs(output, name, node, expression);
        }
      }
    }
  }
  return null;
}

bool methodInvocationContainsNamedParam(MethodInvocation methodInvocation, String paramName) {
  return methodInvocation.argumentList.arguments.any((a) => a is NamedExpression && a.name.label.token.value() == paramName);
}

/// Generates internationalisations for the Strings class
class IntlNameGenerator extends Generator {

  const IntlNameGenerator();

  @override
  Future<String> generate(LibraryReader library, _) async {
    var output = new StringBuffer();

    for (ClassElement classElement
    in library.allElements.where((e) => e is ClassElement)) {
      if (classElement.displayName == "SourceStrings") {

        output.writeln("import 'package:flutter/material.dart';");
        output.writeln("import 'package:intl/intl.dart';");
        output.writeln();
        output.writeln("//");
        output.writeln('class Strings {');
        output.writeln('  static Strings of(BuildContext context) {');
        output.writeln('    return Localizations.of<Strings>(context, Strings);');
        output.writeln('  }');

        // Process strings defined as property getter functions
        for (PropertyAccessorElement propElem in classElement.accessors) {
          String propStr = getIntlCreatorSource(propElem);
          if (propStr != null) {
            output.writeln("  " + propStr);
          }
          // Output any getters returning non-translated strings as-is
          else {
            AstNode node = propElem.computeNode();
            if (node is MethodDeclaration) {
              if (node.returnType.toString() == "String") {
                output.writeln("  " + node.toString());
              }
            }
          }
        }

        // Process strings defined as methods
        for (MethodElement methodElem in classElement.methods) {
          String methodStr = getIntlCreatorSource(methodElem);
          if (methodStr != null) {
            output.writeln("  " + methodStr);
          }
        }

        output.writeln('}');

      }
    }

    return '$output';
  }

  @override
  String toString() => 'Auto Intl Generator';
}
