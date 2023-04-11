enum FieldRename {
  camel,
  constant,
  sentence,
  snake,
  dot,
  param,
  path,
  pascal,
  header,
  title,
}

class BuilderConfig {
  final FieldRename fieldRename;

  BuilderConfig._internal({
    required this.fieldRename,
  });

  factory BuilderConfig(Map<String, dynamic> config) {
    return BuilderConfig._internal(
      fieldRename: FieldRename.values.firstWhere(
        (element) => element.name == config['field_rename'],
        orElse: () => FieldRename.snake,
      ),
    );
  }
}
