import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:serviced/serviced.dart';
import 'package:transmute/util.dart';

String? knownKey;

class OpenAIService extends Service {
  @override
  void onStart() {
    String k = knownKey ?? _findAPIKey();
    OpenAI.apiKey = k;
    v("OpenAI is using API Key $k");
  }

  @override
  void onStop() {}

  String _findAPIKey() {
    String? key = _findAPIKeyEnv(["openai_key", "openai", "openai"]);

    if (key == null) {
      throw Exception("Couldnt find the api key! Try with -v");
    }

    return key;
  }

  String? _findAPIKeyEnv(List<String> keys) =>
      keys.expand((element) => [element, element.toUpperCase()]).map((e) {
        v("Checking Env $e for OpenAPI Key");
        return Platform.environment[e];
      }).firstOrNull;
}
