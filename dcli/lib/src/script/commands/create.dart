import 'package:path/path.dart' as p;

import '../../../dcli.dart';
import '../../../posix.dart';
import '../command_line_runner.dart';
import '../flags.dart';
import 'commands.dart';

/// implementation of the 'create' command
class CreateCommand extends Command {
  ///
  CreateCommand() : super(_commandName);
  static const String _commandName = 'create';

  final _createFlags = [ForegroundFlag()];

  /// holds the set of flags passed to the compile command.
  Flags flagSet = Flags();

  late DartScript _script;

  @override
  int run(List<Flag> selectedFlags, List<String> subarguments) {
    var scriptIndex = 0;

    if (Shell.current.isSudo) {
      printerr('You cannot create a script as sudo.');
      return 1;
    }

    // check for any flags
    for (var i = 0; i < subarguments.length; i++) {
      final subargument = subarguments[i];

      if (Flags.isFlag(subargument)) {
        final flag = flagSet.findFlag(subargument, _createFlags);

        if (flag != null) {
          if (flagSet.isSet(flag)) {
            throw DuplicateOptionsException(subargument);
          }
          flagSet.set(flag);
          verbose(() => 'Setting flag: ${flag.name}');
          continue;
        } else {
          throw UnknownFlag(subargument);
        }
      }
      scriptIndex = i;

      final pathToScript =
          _validateArguments(selectedFlags, subarguments.sublist(scriptIndex));

      late DartProject? project;

      if (pathToScript.endsWith('.dart')) {
        final project =
            DartProject.findProject(dirname(pathToScript), search: false);

        if (project == null) {
          printerr(red('The current directory is not a Dart Project. '
              'Use dcli create <projectname> to create a project.'));
          return 1;
        }
        //  DartProje
      }

      print(green('Creating script...'));

      /// There is a question here about whether we should
      /// always create a pubspec.yaml
      /// or do we search for a parent pubspec.yaml.
      /// For now we have decided to always create one.
      project = DartProject.fromPath(dirname(pathToScript), search: false);

      try {
        _script = project.createScript(pathToScript);
      } on TemplateNotFoundException catch (e) {
        printerr(red(e.message));
        print('Install DCli and try again.');
        print(blue(Shell.current.installInstructions));
        return 1;
      }

      break;
    }

    //project.warmup(background: !flagSet.isSet(ForegroundFlag()));

    if (!Settings().isWindows) {
      chmod(p.join(_script.pathToScriptDirectory, _script.scriptName),
          permission: '755');
    }

    print('');

    print('To run your script:\n   ./${_script.scriptName}');

    return 0;
  }

  /// returns the script path.
  String _validateArguments(List<Flag> selectedFlags, List<String> arguments) {
    if (arguments.length != 1) {
      throw InvalidArguments(
        'The create command takes only one argument. '
        'Found: ${arguments.join(',')}',
      );
    }
    final scriptPath = arguments[0];
    if (extension(scriptPath) != '.dart') {
      throw InvalidArguments(
        "The create command expects a script path ending in '.dart'. "
        'Found: $scriptPath',
      );
    }

    if (exists(scriptPath)) {
      throw InvalidArguments(
        'The script ${truepath(scriptPath)} already exists.',
      );
    }

    /// check the script directory exists
    if (!exists(dirname(scriptPath))) {
      throw InvalidArguments('The script directory '
          '${truepath(dirname(scriptPath))} must already exist.');
    }
    return arguments[0];
  }

  @override
  String description() =>
      'Creates a script file with a default pubspec annotation '
      'and a main entry point.';

  @override
  String usage() => 'create [--foreground] <script path.dart>';

  @override
  List<String> completion(String word) => <String>[];

  @override
  List<Flag> flags() => _createFlags;
}

///
class ForegroundFlag extends Flag {
  ///
  ForegroundFlag() : super(_flagName);

  static const _flagName = 'foreground';

  @override
  String get abbreviation => 'fg';

  @override
  String description() =>
      '''Stops the create from running pub get in the background.''';
}