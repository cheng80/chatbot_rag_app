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
}
