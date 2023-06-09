// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:surrealdb_dart_orm/src/extensions/dart_type_extension.dart';
import 'package:surrealdb_dart_orm_annotations/surrealdb_dart_orm_annotations.dart';

import '../../constants.dart';
import '../../surrealdb_model_field.dart';
import '../../surrealdb_model_visitor.dart';

class SurrealDBWhereClauseGenerator
    extends GeneratorForAnnotation<SurrealDBModel> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final visitor = SurrealDBModelVisitor();
    element.visitChildren(visitor);
    if (visitor.className.isEmpty) {
      return '';
    }
    final stringBuffer = StringBuffer();
    final className = visitor.className;
    final fields = visitor.fields;
    final generatedClassName = '$className$kWhereClauseClassPrefix';
    stringBuffer
      ..writeln('class $generatedClassName {')
      ..writeln('final $kFieldNameToStoreClauses = <String>[];');
    final operatorsMap = {
      '=': {
        'name': 'EqualsTo',
        'supportsDynamicType': true,
      },
      '!=': {
        'name': 'NotEqualsTo',
      },
      '==': {
        'name': 'ExactlyEqualsTo',
      },
      '>': {
        'name': 'GreaterThan',
      },
      '>=': {
        'name': 'GreaterThanOrEqualsTo',
      },
      '<': {
        'name': 'LessThan',
      },
      '<=': {
        'name': 'LessThanOrEqualsTo',
      },
    };
    for (final entry in operatorsMap.entries) {
      stringBuffer.writeln(
        _generateOperatorMethod(
          className: className,
          fields: fields,
          operator: entry.key,
          methodPrefix: entry.value['name']!.toString(),
          supportsDynamicType: entry.value['supportsDynamicType'] == true,
        ),
      );
    }
    final truthyOperatorsMap = {
      '&&': 'ampersandAnd',
      '||': 'pipeOr',
      'AND': 'and',
      'OR': 'or',
    };
    for (final entry in truthyOperatorsMap.entries) {
      stringBuffer.writeln(
        _generateTruthyOperatorMethod(
          operator: entry.key,
          methodPrefix: entry.value,
        ),
      );
    }
    stringBuffer
      ..writeln(_generateToStringMethod())
      ..writeln('}');
    return stringBuffer.toString();
  }

  StringBuffer _generateOperatorMethod({
    required String className,
    required Iterable<SurrealDBModelField> fields,
    required String operator,
    required String methodPrefix,
    bool supportsDynamicType = false,
  }) {
    String buildValue(DartType type, String parameterName) {
      final stringBuffer = StringBuffer();
      if (type.shouldAddApostrophe) {
        stringBuffer.write('\\"');
      }
      if (parameterName == kIdFieldName) {
        stringBuffer.write('${className.toLowerCase()}:');
      }
      stringBuffer.write('\$$parameterName');
      if (type.shouldAddApostrophe) {
        stringBuffer.write('\\"');
      }
      return stringBuffer.toString();
    }

    final stringBuffer = StringBuffer();
    for (final field in fields) {
      final fieldType = field.type.getDisplayString(
        withNullability: field.name != kIdFieldName,
      );
      stringBuffer
        ..writeln('void ${field.name}$methodPrefix(')
        ..writeln(
            '${supportsDynamicType ? 'dynamic' : fieldType} ${field.name}')
        ..writeln(') {')
        ..writeln(
          '$kFieldNameToStoreClauses.add("${field.name} $operator ${buildValue(field.type, field.name)}");',
        )
        ..writeln('}');
    }
    return stringBuffer;
  }

  StringBuffer _generateTruthyOperatorMethod({
    required String operator,
    required String methodPrefix,
  }) {
    final stringBuffer = StringBuffer();
    stringBuffer
      ..writeln('void $methodPrefix() {')
      ..writeln('clauses.add(" $operator ");')
      ..writeln('}');
    return stringBuffer;
  }

  StringBuffer _generateToStringMethod() {
    final stringBuffer = StringBuffer();
    stringBuffer
      ..writeln('@override')
      ..writeln('String toString() {')
      ..writeln('final stringBuffer = StringBuffer();')
      ..writeln('if ($kFieldNameToStoreClauses.isNotEmpty) {')
      ..write('stringBuffer.write("WHERE ");')
      ..write('stringBuffer.write($kFieldNameToStoreClauses.join());')
      ..writeln('}')
      ..writeln('return stringBuffer.toString();')
      ..writeln('}');
    return stringBuffer;
  }
}
