import 'package:args/command_runner.dart';
import 'package:fast_log/fast_log.dart';
import 'package:serviced/serviced.dart';
import 'package:transmute/services/open_ai_service.dart';
import 'package:transmute/util.dart';

late CommandRunner _runner;

void main(List<String> arguments) {
  _runner = CommandRunner("transmute", "A source conversion tool");
  _runner.argParser.addFlag("verbose",
      abbr: 'v',
      help: "Verbose logging",
      defaultsTo: false,
      callback: (k) => verboseMode = k);
  _runner.argParser.addOption("openai-key",
      abbr: "k", defaultsTo: "", callback: (k) => knownKey = k ?? knownKey);
  lDebugMode = true;
  services().register(() => OpenAIService());
}
