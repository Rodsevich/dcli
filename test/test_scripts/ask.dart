#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';

/// dshell script generated by:
/// dshell create ask.dart
///
/// See
/// https://pub.dev/packages/dshell#-installing-tab-
///
/// For details on installing dshell.
///

void main() {
  var name = ask(prompt: 'tell me your name:');
  print('your name is: $name');
}