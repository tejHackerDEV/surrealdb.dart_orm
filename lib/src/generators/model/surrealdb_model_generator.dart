// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:surrealdb_dart_orm_annotations/surrealdb_dart_orm_annotations.dart';

import '../../constants.dart';
import '../../surrealdb_model_field.dart';
import '../../surrealdb_model_visitor.dart';

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
    final idField = visitor.idField!;
    final fields = visitor.fields;
    final generatedClassName = '$className$kModelClassPrefix';
    stringBuffer
      ..writeln('class $generatedClassName {')
      ..writeln(
        _generateInsertMethod(
          className: className,
          fields: fields,
        ),
      )
      ..writeln(
        _generateSelectMethod(
          className: className,
        ),
      )
      ..writeln(
        _generateSelectByIdMethod(
          className: className,
          idType: idField.type,
        ),
      )
      ..writeln('}');
    return stringBuffer.toString();
  }

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
        'final results = await surrealdb.create("${className.toLowerCase()}", data.toJson(),);',
      )
      ..writeln('if (results.length != 1) {')
      ..writeln('return null;')
      ..writeln('}')
      ..writeln('return $className.fromJson(results.first.value);');
    stringBuffer.write('}');
    return stringBuffer;
  }

  StringBuffer _generateSelectMethod({
    required String className,
  }) {
    final stringBuffer = StringBuffer();
    stringBuffer
      ..writeln('static Future<Iterable<$className>> select({')
      ..writeln('$className$kWhereClauseClassPrefix? where,')
      ..writeln('}) async {')
      ..writeln(
        'final results = await surrealdb.query(',
      )
      ..write('"SELECT * FROM ${className.toLowerCase()}')
      ..writeln(' \${where == null ? "" : where}",')
      ..writeln(');')
      ..writeln('if (results.isEmpty) {')
      ..writeln('return [];')
      ..writeln('}')
      ..writeln(
        'return results.first.result.map((result) => $className.fromJson(result));',
      )
      ..write('}');
    return stringBuffer;
  }

  StringBuffer _generateSelectByIdMethod({
    required String className,
    required DartType idType,
  }) {
    String idStringType = idType.getDisplayString(withNullability: false);
    final stringBuffer = StringBuffer();
    stringBuffer
      ..writeln('static Future<$className?> selectById(')
      ..writeln('$idStringType id,')
      ..writeln(') async {')
      ..writeln(
        'final results = await surrealdb.select("${className.toLowerCase()}:\$id");',
      )
      ..writeln('if (results.isEmpty) {')
      ..writeln('return null;')
      ..writeln('}')
      ..writeln(
        'return $className.fromJson(results.first.value);',
      )
      ..write('}');
    return stringBuffer;
  }
}
