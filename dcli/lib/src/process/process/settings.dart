// @dart=3.0

import 'package:dcli_core/dcli_core.dart';

import '../../shell/shell.dart';
import '../environment.dart';

class ProcessSettings {
  ProcessSettings(
    this.command, {
    this.args = const <String>[],
    String? workingDirectory,
    this.runInShell = false,
    this.detached = false,
    this.waitForStart = true,
    this.terminal = false,
    this.privileged = false,
    this.extensionSearch = true,
  }) : environment = ProcessEnvironment() {
    this.workingDirectory = workingDirectory ??= pwd;

    /// If privileged has been requested we pass
    /// the privileged status of the user across
    /// as the Shell details will probably cached in this
    /// isolate but not the called isolate.
    if (privileged) {
      isPriviledgedUser = Shell.current.isPrivilegedUser;
    }
  }

  final String command;
  final List<String> args;
  late final String workingDirectory;

  // environment variables
  ProcessEnvironment environment;

  bool runInShell = false;
  bool detached = false;
  bool waitForStart = true;
  bool terminal = false;
  bool privileged = false;
  bool extensionSearch = true;

  bool isPriviledgedUser = false;
}
