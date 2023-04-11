import 'package:surrealdb_dart_orm/src/extensions/field_rename_extension.dart';

import 'builder_options.dart';

class Utils {
  static StringBuffer generateThing(String generatedModelName) {
    final stringBuffer = StringBuffer();
    stringBuffer
      ..writeln('String thing = $generatedModelName.tableName;')
      // If the id is not null then append it to the `thing` by
      // checking whether `id` starsWith the `tableName` or not.
      //
      // If it is, then use `id` as the thing directly,
      // else append `id` to the `tableName`.
      ..writeln('if (id is String) {')
      ..writeln('if (!id.startsWith(thing)) {')
      ..writeln('thing += ":\$id";')
      ..writeln('}')
      ..writeln('else {')
      ..writeln('thing = id;')
      ..writeln('}')
      ..writeln('}');
    return stringBuffer;
  }

  /// Generate the code that will insert timestamp
  /// into the `jsonData` based on the [forCreated].
  static StringBuffer generateUtcTimeStamp({
    required bool forCreated,
    required FieldRename fieldRename,
  }) {
    final stringBuffer = StringBuffer();
    stringBuffer.writeln(
      'jsonData["${fieldRename.convert(forCreated ? 'createdAt' : 'updatedAt')}"] = DateTime.now().toUtc().toIso8601String();',
    );
    return stringBuffer;
  }
}
