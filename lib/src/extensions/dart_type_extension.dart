// ignore_for_file:  depend_on_referenced_packages

import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

extension DartTypeExtension on DartType {
  bool get isEnum => TypeChecker.fromRuntime(Enum).isAssignableFromType(this);
}
