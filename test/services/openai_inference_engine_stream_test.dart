import 'dart:convert';

import 'package:fala/services/inference/inference_engine.dart';
import 'package:fala/services/inference/openai_inference_engine.dart';
import 'package:fala/services/settings/api_key_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

OpenAIClient _clientWith(http.Client httpClient) =>
    OpenAIClient.withApiKey('sk-test', httpClient: httpClient);

/// A schema with nothing tutor-specific in it: the engine passes on whatever
/// it is given.
const _testSchema = <String, dynamic>{
  'type': 'object',
  'additionalProperties': false,
  'required': ['reply'],
  'properties': {
    'reply': {'type': 'string'},
  },
};

OpenAiInferenceEngine _engineWith({
  required http.Client httpClient,
  required ApiKeyStore store,
  String model = 'gpt-4o-mini',
}) {
  return OpenAiInferenceEngine(
    apiKeyStore: store,
    modelProvider: () => model,
    schemaName: 'test_reply',
    schema: _testSchema,
    clientBuilder: (_) => _clientWith(httpClient),
  );
}

/// Builds an OpenAI chat-completions SSE body from a list of content deltas.
String _sse(List<String> contents) {
  final buf = StringBuffer();
  for (final content in contents) {
    final chunk = {
      'id': 'chatcmpl-1',
      'object': 'chat.completion.chunk',
      'created': 1,
      'model': 'gpt-4o-mini',
      'choices': [
        {
          'index': 0,
          'delta': {'content': content},
          'finish_reason': null,
        },
      ],
    };
    buf.write('data: ${jsonEncode(chunk)}\n\n');
  }
  buf.write('data: [DONE]\n\n');
  return buf.toString();
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('streams cumulative buffers from content deltas', () async {
    final store = ApiKeyStore();
    await store.write('sk-test');
    final mock = MockClient((request) async {
      expect(request.url.path, endsWith('/chat/completions'));
      return http.Response(
        _sse(['{"correction"', ':{"content"', ':"Oi"}}']),
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    });
    final engine = _engineWith(httpClient: mock, store: store);
    await engine.initialize();

    final emissions = await engine
        .generateStream(const InferenceRequest(prompt: 'oi'))
        .toList();

    expect(emissions, [
      '{"correction"',
      '{"correction":{"content"',
      '{"correction":{"content":"Oi"}}',
    ]);
  });

  Future<Map<String, dynamic>> sentBodyFor(String model) async {
    final store = ApiKeyStore();
    await store.write('sk-test');
    late Map<String, dynamic> body;
    final mock = MockClient((request) async {
      body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        _sse(['{"reply":"oi"}']),
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    });
    final engine = _engineWith(httpClient: mock, store: store, model: model);
    await engine.initialize();
    await engine.generateStream(const InferenceRequest(prompt: 'oi')).toList();
    return body;
  }

  test('sends reasoning_effort none for an offered reasoning model', () async {
    final body = await sentBodyFor('gpt-5.4-nano');
    expect(body['model'], 'gpt-5.4-nano');
    expect(body['reasoning_effort'], 'none');
  });

  test('sends the developer prompt as a developer message first', () async {
    final store = ApiKeyStore();
    await store.write('sk-test');
    late Map<String, dynamic> body;
    final mock = MockClient((request) async {
      body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        _sse(['{"reply":"oi"}']),
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    });
    final engine = _engineWith(httpClient: mock, store: store);
    await engine.initialize();
    await engine
        .generateStream(
          const InferenceRequest(prompt: 'oi', developerPrompt: 'rules'),
        )
        .toList();
    final messages = body['messages'] as List<dynamic>;
    expect(messages.map((m) => (m as Map)['role']), ['developer', 'user']);
    expect((messages.first as Map)['content'], 'rules');
  });

  test('sends no reasoning_effort for a model not offered', () async {
    final body = await sentBodyFor('gpt-4o-mini');
    expect(body.containsKey('reasoning_effort'), isFalse);
  });

  test('throws InferenceStreamException when no key is stored', () async {
    final store = ApiKeyStore();
    final engine = _engineWith(
      httpClient: MockClient((_) async => http.Response('', 200)),
      store: store,
    );
    await engine.initialize();

    await expectLater(
      engine.generateStream(const InferenceRequest(prompt: 'oi')).toList(),
      throwsA(
        isA<InferenceStreamException>().having(
          (e) => e.message,
          'message',
          contains('OpenAI key missing or rejected'),
        ),
      ),
    );
  });

  test('maps HTTP 401 to a key-rejected stream failure', () async {
    final store = ApiKeyStore();
    await store.write('sk-bad');
    final mock = MockClient((_) async {
      return http.Response(
        '{"error":{"message":"invalid key","type":"invalid_request_error",'
        '"code":"invalid_api_key"}}',
        401,
        headers: {'content-type': 'application/json'},
      );
    });
    final engine = _engineWith(httpClient: mock, store: store);
    await engine.initialize();

    await expectLater(
      engine.generateStream(const InferenceRequest(prompt: 'oi')).toList(),
      throwsA(
        isA<InferenceStreamException>().having(
          (e) => e.message,
          'message',
          contains('OpenAI key missing or rejected'),
        ),
      ),
    );
  });

  test('maps HTTP 429 to a rate-limit stream failure', () async {
    final store = ApiKeyStore();
    await store.write('sk-test');
    final mock = MockClient((_) async {
      return http.Response(
        '{"error":{"message":"slow down","type":"rate_limit_error"}}',
        429,
        headers: {'content-type': 'application/json'},
      );
    });
    final engine = _engineWith(httpClient: mock, store: store);
    await engine.initialize();

    await expectLater(
      engine.generateStream(const InferenceRequest(prompt: 'oi')).toList(),
      throwsA(
        isA<InferenceStreamException>().having(
          (e) => e.message,
          'message',
          contains('rate limit'),
        ),
      ),
    );
  });

  test('throws when the stream yields no content', () async {
    final store = ApiKeyStore();
    await store.write('sk-test');
    final mock = MockClient((_) async {
      return http.Response(
        _sse(const []), // only [DONE]
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    });
    final engine = _engineWith(httpClient: mock, store: store);
    await engine.initialize();

    await expectLater(
      engine.generateStream(const InferenceRequest(prompt: 'oi')).toList(),
      throwsA(
        isA<InferenceStreamException>().having(
          (e) => e.message,
          'message',
          contains('empty response'),
        ),
      ),
    );
  });
}
