import 'package:flutter_test/flutter_test.dart';

import 'package:chatbot_rag_app/vm/tourism_chat_state.dart';

void main() {
  test('clarification response keeps follow-up type and suggestions', () {
    final state = parseTourismChatResponse({
      'answer': '중구가 여러 지역에 있어요.',
      'lookup_mode': 'clarification',
      'cards': [],
      'sources': [],
      'suggested_messages': ['서울 중구에서 휠체어 관광지 추천해줘'],
    });

    expect(state.clarificationType, isNotNull);
    expect(state.suggestionType, state.clarificationType);
    expect(state.suggestions, contains('서울 중구에서 휠체어 관광지 추천해줘'));
  });

  test('chat response keeps latest backend contract fields', () {
    final state = parseTourismChatResponse({
      'answer': '서울 강남구 기준으로 확인했어요.',
      'lookup_mode': 'live_update_pending',
      'live_update_pending': true,
      'live_update_id': 'update-1',
      'reasoning_assist_used': true,
      'reasoning_assist_notes': ['카드 근거만 사용했습니다.'],
      'warnings': ['방문 전 현장 확인이 필요합니다.'],
      'suggested_messages': ['최신 정보 더 찾기'],
      'sources': [],
      'cards': [
        {
          'content_id': '123',
          'title': '서울 선릉과 정릉',
          'address': '서울특별시 강남구 선릉로100길 1',
          'recommendation_reason': '휠체어 동선을 확인할 수 있습니다.',
          'source_name': '한국관광공사 무장애 여행 정보',
          'source_url': 'https://access.visitkorea.or.kr/detail/123',
          'accessibility': {'wheelchair': '일부 구간 확인 필요'},
          'raw_fields': {'휠체어': '일부 구간 확인 필요'},
          'accessibility_tags': ['휠체어 접근'],
          'family_tags': [],
        },
      ],
    });

    expect(state.requestState, '최신 후보 확인 중');
    expect(state.liveUpdatePending, isTrue);
    expect(state.liveUpdateId, 'update-1');
    expect(state.cards.single.contentId, '123');
    expect(state.cards.single.sourceUrl, isEmpty);
    expect(state.sources.single.url, isNull);
    expect(state.diagnostics, contains('최신 후보 확인이 늦게 도착할 수 있습니다.'));
    expect(state.diagnostics, contains('복합 조건을 반영하기 위해 추론 보조로 후보 순서를 조정했습니다.'));
    expect(state.diagnostics, contains('추론 보조 메모: 카드 근거만 사용했습니다.'));
    expect(state.diagnostics, contains('방문 전 현장 확인이 필요합니다.'));
  });
}
