// ignore_for_file: depend_on_referenced_packages

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

import 'constants.dart';
import 'surrealdb_model_field.dart';

class SurrealDBModelVisitor extends SimpleElementVisitor<void> {
  late String className;
  SurrealDBModelField? idField;
  List<SurrealDBModelField> fields = [];

  @override
  void visitClassElement(ClassElement element) {}

  @override
  void visitConstructorElement(ConstructorElement element) {
    if (element.name.isEmpty) {
      className = element.displayName;
      element.children.whereType<ParameterElement>().forEach((element) {
        final field = SurrealDBModelField(
          name: element.name,
          type: element.type,
          isRequired: element.isRequired,
        );
        if (element.name == kIdFieldName) {
          idField = field;
          if (!field.type.isDartCoreString) {
            throw ArgumentError.value(
              field.type,
              'id',
              'Type should be of String? but found ${field.type}',
            );
          }
        }
        fields.add(field);
      });
    }
  }

  @override
  void visitFieldElement(FieldElement element) {
    print(element.name);
    print(element.type.toString());
  }
}
