// ignore_for_file:  depend_on_referenced_packages

import 'package:analyzer/dart/element/type.dart';

extension DartTypeExtension on DartType {
  bool get shouldAddApostrophe {
    if (isDartCoreString) {
      return true;
    }
    return false;
  }
}
