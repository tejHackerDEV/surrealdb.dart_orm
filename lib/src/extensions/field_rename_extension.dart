// ignore_for_file:  depend_on_referenced_packages

import 'package:recase/recase.dart';

import '../builder_options.dart';

extension FieldRenameExtension on FieldRename {
  String convert(String fieldName) {
    switch (this) {
      case FieldRename.camel:
        return fieldName.camelCase;
      case FieldRename.constant:
        return fieldName.constantCase;
      case FieldRename.sentence:
        return fieldName.sentenceCase;
      case FieldRename.snake:
        return fieldName.snakeCase;
      case FieldRename.dot:
        return fieldName.dotCase;
      case FieldRename.param:
        return fieldName.paramCase;
      case FieldRename.path:
        return fieldName.pathCase;
      case FieldRename.pascal:
        return fieldName.pascalCase;
      case FieldRename.header:
        return fieldName.headerCase;
      case FieldRename.title:
        return fieldName.titleCase;
    }
  }
}
