import 'dart:io';
import 'package:args/args.dart';


void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('generate')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print this usage info.');

  final generateParser = parser.commands['generate']!
    ..addOption('output', abbr: 'o', defaultsTo: 'lib/client.dart', help: 'Output file path')
    ..addOption('name', abbr: 'n', defaultsTo: 'ApiClient', help: 'Name of the generated class')
    ..addOption('base-url', abbr: 'b', defaultsTo: 'http://localhost:3000', help: 'Default base URL')
    ..addFlag('riverpod', help: 'Generate Riverpod providers (requires flutter_riverpod)', defaultsTo: false);

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      print('Rivet CLI Tool');
      print('Usage: dart run rivet <command> [arguments]');
      print('');
      print('Commands:');
      print('  generate    Generate a Dart API client from your controllers');
      print('');
      print('Generate Options:');
      print(generateParser.usage);
      return;
    }

    if (results.command?.name == 'generate') {
      await _handleGenerate(results.command!);
    } else {
      print('Rivet CLI Tool');
      print('Usage: dart run rivet <command> [arguments]');
      print('Run "dart run rivet --help" for more information.');
    }
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

Future<void> _handleGenerate(ArgResults args) async {
  print('🔨 Rivet Client Generator');
  
  final output = args['output'] as String;
  final className = args['name'] as String;
  final baseUrl = args['base-url'] as String;
  final useRiverpod = args['riverpod'] as bool;

  print('   Scanning project for controllers...');

  // 1. Find all Dart files in lib/
  final libDir = Directory('lib');
  if (!await libDir.exists()) {
    print('Error: lib/ directory not found. Are you in the root of your project?');
    exit(1);
  }

  final dartFiles = await libDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();

  if (dartFiles.isEmpty) {
    print('Error: No Dart files found in lib/');
    exit(1);
  }

  // 2. Generate a temporary runner script
  // This script imports all project files so mirrors can find the controllers
  final runnerFile = File('.rivet_gen_runner.dart');
  final buffer = StringBuffer();

  buffer.writeln("import 'dart:mirrors';");
  buffer.writeln("import 'dart:io';");
  buffer.writeln("import 'package:rivet/rivet.dart';");
  buffer.writeln("import 'package:rivet/src/codegen/metadata_extractor.dart';");
  buffer.writeln("import 'package:rivet/src/codegen/dart_client_generator.dart';");
  buffer.writeln();
  
  // Import all user files
  // We use relative paths from project root
  for (final file in dartFiles) {
    // Convert file path to package import or relative import
    // For simplicity in this runner, we'll relative imports, but we need to handle the fact
    // that the runner is in the root.
    buffer.writeln("import '${file.path}';");
  }

  buffer.writeln();
  buffer.writeln("void main() async {");
  buffer.writeln("  print('   🔍 Analyzing metadata...');");
  buffer.writeln("  final controllers = <ControllerMetadata>[];");
  buffer.writeln("  final extractor = ControllerMetadataExtractor();");
  buffer.writeln();
  buffer.writeln("  // Scan all loaded libraries for classes with @RivetController");
  buffer.writeln("  final mirrorSystem = currentMirrorSystem();");
  buffer.writeln("  ");
  buffer.writeln("  for (final library in mirrorSystem.libraries.values) {");
  buffer.writeln("    for (final declaration in library.declarations.values) {");
  buffer.writeln("      if (declaration is ClassMirror) {");
  buffer.writeln("        bool isController = false;");
  buffer.writeln("        for (final metadata in declaration.metadata) {");
  buffer.writeln("          if (metadata.reflectee is RivetController) {");
  buffer.writeln("            isController = true;");
  buffer.writeln("            break;");
  buffer.writeln("          }");
  buffer.writeln("        }");
  buffer.writeln("        ");
  buffer.writeln("        if (isController) {");
  buffer.writeln("          try {");
  buffer.writeln("            // We need to instantiate the controller to extract metadata");
  buffer.writeln("            // This assumes a default constructor exists");
  buffer.writeln("            // In a real framework we might use valid static analysis,");
  buffer.writeln("            // but for this v2.0 feature we instantiate.");
  buffer.writeln("            final instance = declaration.newInstance(Symbol(''), []).reflectee;");
  buffer.writeln("            print('   Found controller: \${MirrorSystem.getName(declaration.simpleName)}');");
  buffer.writeln("            controllers.add(extractor.extractFromController(instance));");
  buffer.writeln("          } catch (e) {");
  buffer.writeln("            print('   Warning: Could not check \${MirrorSystem.getName(declaration.simpleName)}: \$e');");
  buffer.writeln("          }");
  buffer.writeln("        }");
  buffer.writeln("      }");
  buffer.writeln("    }");
  buffer.writeln("  }");
  buffer.writeln();
  buffer.writeln("  if (controllers.isEmpty) {");
  buffer.writeln("    print('   ⚠️ No controllers found.');");
  buffer.writeln("    return;");
  buffer.writeln("  }");
  buffer.writeln();
  buffer.writeln("  print('   🚀 Generating code...');");
  buffer.writeln("  final generator = DartClientGenerator(");
  buffer.writeln("    controllers: controllers,");
  buffer.writeln("    className: '$className',");
  buffer.writeln("    baseUrl: '$baseUrl',");
  buffer.writeln("    includeRiverpod: $useRiverpod,");
  buffer.writeln("  );");
  buffer.writeln();
  buffer.writeln("  final code = generator.generate();");
  buffer.writeln("  final file = File('$output');");
  buffer.writeln("  await file.parent.create(recursive: true);");
  buffer.writeln("  await file.writeAsString(code);");
  buffer.writeln("  print('   ✅ Generated client in $output');");
  buffer.writeln("}");

  await runnerFile.writeAsString(buffer.toString());

  // 3. Run the temporary script
  print('   Running generation script...');
  // We need to include the current package in specific ways if not careful, 
  // but 'dart run file.dart' generally works if pubspec is set up.
  
  final process = await Process.start('dart', ['run', runnerFile.path]);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  
  final exitCode = await process.exitCode;
  
  // 4. Cleanup
  if (await runnerFile.exists()) {
    await runnerFile.delete();
  }
  
  if (exitCode == 0) {
    print('✨ Done!');
  } else {
    print('❌ Generation failed with exit code $exitCode');
    exit(exitCode);
  }
}
