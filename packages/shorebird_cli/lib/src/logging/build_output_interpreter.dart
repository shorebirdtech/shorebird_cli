class BuildOutputInterpreter {
  (List<String>, String?) interpret({
    required String stdout,
    required String stderr,
  }) {
    final stdoutMessage = errorMessageFromOutput(stdout);
    if (stdoutMessage.isNotEmpty) {
      return (stdoutMessage, recommendationFromOutput(stdoutMessage));
    }

    final stderrMessage = errorMessageFromOutput(stderr);
    if (stderrMessage.isNotEmpty) {
      return (stderrMessage, recommendationFromOutput(stderrMessage));
    }

    return ([], null);
  }
}

String? recommendationFromOutput(List<String> output) {
  if (output.any((l) => l.contains(''))) {
    return 'KEYSTORE ERROR';
  }

  return null;
}

List<String> errorMessageFromOutput(String output) {
  final failureHeader =
      RegExp(r'.*FAILURE: Build failed with an exception\..*');
  final failureFooter1 = RegExp(r'.*\* Exception is:.*');
  final failureFooter2 = RegExp(r'.*\* Try:.*');

  String trimLine(String line) {
    return line.trim().replaceAll(RegExp(r'^\[.*\]'), '');
  }

  bool inErrorOutput = false;
  final ret = <String>[];
  for (final line in output.split('\n')) {
    if (failureHeader.hasMatch(line)) {
      inErrorOutput = true;
    } else if (failureFooter1.hasMatch(line) || failureFooter2.hasMatch(line)) {
      inErrorOutput = false;
    }

    if (inErrorOutput) {
      ret.add(trimLine(line));
    }
  }

  return ret;
}
