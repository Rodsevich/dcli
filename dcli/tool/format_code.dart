#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

/// dcli script generated by:
/// dcli create format_code.dart
///
/// See
/// https://pub.dev/packages/dcli#-installing-tab-
///
/// For details on installing dcli.
///

void main() {
  'dartfmt -w ../bin ../lib ../test'.run;
}