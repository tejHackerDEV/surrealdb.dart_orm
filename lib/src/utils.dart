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
}
