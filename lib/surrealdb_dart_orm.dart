import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/surrealdb_model_generator.dart';

Builder surrealdbModelBuilder(BuilderOptions options) => SharedPartBuilder(
      [SurrealDBModelGenerator()],
      'surrealdb_dart_model',
    );
