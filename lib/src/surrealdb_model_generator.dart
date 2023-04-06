// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:surrealdb_dart_orm_annotations/surrealdb_dart_orm_annotations.dart';

import 'surrealdb_model_field.dart';
import 'surrealdb_model_visitor.dart';

class SurrealDBModelGenerator extends GeneratorForAnnotation<SurrealDBModel> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final visitor = SurrealDBModelVisitor();
    element.visitChildren(visitor);
    if (visitor.className.isEmpty) {
      return '';
    }
    final stringBuffer = StringBuffer();
    final className = visitor.className;
    final fields = visitor.fields;
    final generatedClassName = '${className}Model';
    stringBuffer
      ..writeln('class $generatedClassName {')
      ..writeln(
        _generateInsertMethod(
          className: className,
          fields: fields,
        ),
      )
      ..writeln('}');
    return stringBuffer.toString();
  }

  /// Generates code for insert method
  StringBuffer _generateInsertMethod({
    required String className,
    required Iterable<SurrealDBModelField> fields,
  }) {
    final stringBuffer = StringBuffer();
    stringBuffer.writeln('static Future<$className?> insert({');
    for (final field in fields) {
      if (field.isRequired) {
        stringBuffer.write('required ');
      }
      stringBuffer.write('${field.type} ${field.name},');
    }
    stringBuffer.writeln('}) async {');
    stringBuffer.write('final data = $className(');
    for (final field in fields) {
      final name = field.name;
      stringBuffer.write('$name: $name, ');
    }
    stringBuffer.writeln(');');
    stringBuffer
      ..writeln(
        'final results = await surrealdb.create("${className.toLowerCase()}", data);',
      )
      ..writeln('if (results.length != 1) {')
      ..writeln('return null;')
      ..writeln('}')
      ..writeln('return $className.fromJson(results.first.value);');
    stringBuffer.write('}');
    return stringBuffer;
  }
}
