import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fast_log/fast_log.dart';

class EditCommand extends Command {
  @override
  String get description => "Edits a file";

  @override
  String get name => "edit";

  EditCommand() {
    argParser.addOption("find",
        abbr: 'f',
        help: "Find absolute text or regex with the -x flag.",
        mandatory: true);
    argParser.addOption("replace",
        abbr: 'r', help: "Replace all finds with this text", mandatory: true);
    argParser.addOption("input",
        abbr: "i", help: "The file to read", mandatory: true);
    argParser.addOption("output",
        abbr: "o",
        help:
            "The file to write to. If unspecified will write back to the input file.");
    argParser.addFlag("regex",
        abbr: 'x',
        help: "If enabled the find option will be treated as regex",
        defaultsTo: false);
  }

  @override
  Future<void> run() async {
    String? find = argResults?["find"];
    String? replace = argResults?["replace"];
    String? input = argResults?["input"];
    String? output = argResults?["output"] ?? input;
    bool regex = argResults?["regex"] ?? false;
    Pattern pattern = regex ? RegExp(find!) : find!;
    return execute(
        find: find,
        replace: replace!,
        input: input!,
        output: output!,
        pattern: pattern,
        streamable: input != output && !find!.contains("\n") && !regex,
        regex: regex);
  }

  Future<void> execute({
    required String find,
    required String replace,
    required String input,
    required String output,
    bool regex = false,
    bool streamable = false,
    required Pattern pattern,
  }) async {
    if (streamable) {
      Completer<bool> completer = Completer<bool>();
      Stream<List<int>> inputStream = File(input!).openRead();
      IOSink out = File(output!).openWrite(mode: FileMode.writeOnly);
      inputStream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
              (String line) => out.writeln(line.replaceAll(pattern, replace!)),
              onDone: () async {
        await out.flush();
        await out.close();
        completer.complete(true);
      }, onError: (e) async {
        error(e.toString());
        await out.flush();
        await out.close();
        completer.complete(false);
      });
      await completer.future;
    } else {
      await File(output!).writeAsString(await File(input!)
          .readAsString()
          .then((value) => value.replaceAll(pattern, replace!)));
    }
  }
}
