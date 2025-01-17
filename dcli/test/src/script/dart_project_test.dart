@Timeout(Duration(minutes: 10))
library;

/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';
import 'package:dcli_core/dcli_core.dart' as core;
import 'package:path/path.dart' hide equals;
import 'package:pubspec_manager/pubspec_manager.dart';
import 'package:test/test.dart';

void main() {
  test('dart project directories', () async {
    expect(DartProject.fromPath(pwd).pathToProjectRoot, equals(truepath('.')));
    expect(
      DartProject.fromPath(pwd).pathToPubSpec,
      equals(truepath('pubspec.yaml')),
    );
    expect(
      DartProject.fromPath(pwd).pathToDartToolDir,
      equals(truepath('.dart_tool')),
    );
    expect(DartProject.fromPath(pwd).pathToToolDir, equals(truepath('tool')));
    expect(DartProject.fromPath(pwd).pathToBinDir, equals(truepath('bin')));
    expect(DartProject.fromPath(pwd).pathToTestDir, equals(truepath('test')));
  });

  group('Create Project ', () {
    test('Create project full with --template', () async {
      //    await TestFileSystem().withinZone((fs) async {
//        InstallCommand().initTemplates();

      await core.withTempDir((tempDir) async {
        const projectName = 'full_test';
        final pathToProject = join(tempDir, projectName);

        const mainScriptName = '$projectName.dart';
        final scriptPath = join(pathToProject, 'bin', mainScriptName);

        await withEnvironment(() async {
          DartProject.create(pathTo: pathToProject, templateName: 'full');
        }, environment: {
          overrideDCliPathKey: DartProject.self.pathToProjectRoot
        });

        expect(exists(scriptPath), isTrue);
        final project = DartProject.fromPath(pathToProject);
        expect(project.hasPubSpec, isTrue);
        final pubspec = PubSpec.loadFromPath(project.pathToPubSpec);
        final executables = pubspec.executables;
        final mainScriptKey = basenameWithoutExtension(mainScriptName);
        expect(executables.exists(mainScriptKey), isTrue);
        expect(executables[mainScriptKey]!.scriptPath,
            equals(join('bin', '$mainScriptKey.dart')));
      });
    });
    // });
  });
}
