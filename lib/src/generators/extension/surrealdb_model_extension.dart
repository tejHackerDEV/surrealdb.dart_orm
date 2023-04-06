// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:surrealdb_dart_orm_annotations/surrealdb_dart_orm_annotations.dart';

import '../../constants.dart';
import '../../surrealdb_model_field.dart';
import '../../surrealdb_model_visitor.dart';

class SurrealDBModelExtensionGenerator
    extends GeneratorForAnnotation<SurrealDBModel> {
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
    final generatedClassName = '$className$kModelExtensionClassPrefix';
    stringBuffer
      ..writeln('extension $generatedClassName on $className {')
      ..writeln(
        _generateSaveMethod(
          className: className,
          fields: fields,
        ),
      )
      ..writeln('}');
    return stringBuffer.toString();
  }

  StringBuffer _generateSaveMethod({
    required String className,
    required Iterable<SurrealDBModelField> fields,
  }) {
    final stringBuffer = StringBuffer();
    stringBuffer
      ..writeln('Future<$className?> save(')
      ..writeln(') async {')
      ..writeln('final dataToUpdate = toJson();')
      ..writeln('final id = dataToUpdate.remove("id");')
      ..writeln('String thing = "${className.toLowerCase()}";')
      // as id is null we need to call the insert method
      // instead of regular update, if we failed to do so
      // all records in the $className table will be updated
      ..writeln('if (id == null) {')
      ..writeln('return await $className$kModelClassPrefix.insert(');
    for (final field in fields) {
      final name = field.name;
      stringBuffer.write('$name: $name, ');
    }
    stringBuffer
      ..writeln(');')
      ..writeln('}')
      ..writeln('thing += ":\$id";')
      ..writeln(
        'final results = await surrealdb.update(thing, dataToUpdate);',
      )
      ..writeln('if (results.length != 1) {')
      ..writeln('return null;')
      ..writeln('}')
      ..writeln('return $className.fromJson(results.first.value);')
      ..write('}');
    return stringBuffer;
  }
}
