import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  const arbDirectoryPath = 'assets/l10n';
  const outputFilePath = 'lib/generated/localization_accessors.dart';

  final directory = Directory(arbDirectoryPath);
  final files = directory.listSync().whereType<File>().where((file) => file.path.endsWith('.arb'));

  final Set<String> keys = {};

  for (final file in files) {
    final content = await file.readAsString();
    final Map<String, dynamic> data = json.decode(content);
    keys.addAll(data.keys.where((key) => !key.startsWith("@"))); // Skip meta entries
  }

  final outputFile = File(outputFilePath);
  await outputFile.parent.create(recursive: true);
  
  final buffer = StringBuffer();

  buffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND\n");
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln("import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n");
  buffer.writeln("class L10nAccessor {");

  buffer.writeln("  static String get(BuildContext context, String localizationId) {");
  buffer.writeln("    final Map<String, String Function(BuildContext)> localizedStringGetters = {");

  for (final key in keys) {
    buffer.writeln("      '$key': (context) => AppLocalizations.of(context)!.$key,");
  }

  buffer.writeln("    };");
  buffer.writeln("    final getter = localizedStringGetters[localizationId];");
  buffer.writeln("    return getter != null ? getter(context) : localizationId;");
  buffer.writeln("  }");

  buffer.writeln("}");

  await outputFile.writeAsString(buffer.toString());
  print('Localization accessors generated successfully.');
}
