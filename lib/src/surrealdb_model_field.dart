// ignore_for_file: depend_on_referenced_packages

import 'package:analyzer/dart/element/type.dart';

class SurrealDBModelField {
  final String name;
  final String rename;
  final DartType type;
  final bool isRequired;

  SurrealDBModelField({
    required this.name,
    required this.rename,
    required this.type,
    required this.isRequired,
  });
}
