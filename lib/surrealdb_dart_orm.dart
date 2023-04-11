import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/builder_options.dart';
import 'src/generators/extension/surrealdb_model_extension.dart';
import 'src/generators/model/surrealdb_model_generator.dart';
import 'src/generators/where_clause/surrealdb_where_clause_generator.dart';

Builder surrealdbModelBuilder(BuilderOptions options) {
  final builderConfig = BuilderConfig(options.config);
  return SharedPartBuilder(
    [
      SurrealDBModelGenerator(builderConfig),
      SurrealDBWhereClauseGenerator(builderConfig),
      SurrealDBModelExtensionGenerator(builderConfig),
    ],
    'surrealdb_dart_model',
  );
}
