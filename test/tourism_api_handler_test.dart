import 'package:chatbot_rag_app/vm/tourism_api_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fetchRegions reads FastAPI tourism regions contract', () async {
    final handler = TourismApiHandler(
      client: MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.example.com/tourism/regions',
        );
        return http.Response(
          '{"areas":[{"name":"서울","sigungu":["강남구"]}]}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final regions = await handler.fetchRegions('https://api.example.com/');

    expect(regions, hasLength(1));
    expect(regions.first['name'], '서울');
    expect(regions.first['sigungu'], ['강남구']);
  });

  test('chat sends message and session id to FastAPI', () async {
    final handler = TourismApiHandler(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://api.example.com/tourism/chat');
        expect(request.body, contains('"message":"서울 강남구 휠체어"'));
        expect(request.body, contains('"session_id":"session-1"'));
        return http.Response(
          '{"answer":"ok","cards":[],"sources":[],"lookup_mode":"live"}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final response = await handler.chat(
      apiBase: 'https://api.example.com',
      message: '서울 강남구 휠체어',
      sessionId: 'session-1',
    );

    expect(response['answer'], 'ok');
    expect(response['lookup_mode'], 'live');
  });

  test('server errors become TourismApiException', () async {
    final handler = TourismApiHandler(
      client: MockClient(
        (_) async => http.Response(
          '{"detail":{"message":"관광 상담 응답을 만드는 중 문제가 발생했습니다."}}',
          500,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );

    expect(
      () => handler.chat(
        apiBase: 'https://api.example.com',
        message: '질문',
        sessionId: 's',
      ),
      throwsA(isA<TourismApiException>()),
    );
  });
}
