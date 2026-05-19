import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';
import 'tourism_api_handler.dart';
import 'tourism_chat_state.dart';
import 'tourism_models.dart';

final tourismChatNotifierProvider =
    NotifierProvider<TourismChatNotifier, TourismChatState>(
      TourismChatNotifier.new,
    );

class TourismChatNotifier extends Notifier<TourismChatState> {
  late final TourismApiHandler _handler;
  String _sessionId = _createSessionId();

  @override
  TourismChatState build() {
    _handler = TourismApiHandler();
    return TourismChatState.demo(AppConfig.debugUi);
  }

  void showDemo(bool showDebug) {
    state = TourismChatState.demo(showDebug);
  }

  void clear() {
    _sessionId = _createSessionId();
    state = const TourismChatState(
      answer: '질문을 보내면 답변과 추천 카드가 여기에 표시됩니다.',
      sources: [TourismSource(title: '응답 후 한국관광공사 자료와 카드별 출처가 표시됩니다.')],
    );
  }

  Future<void> submit({
    required String apiBase,
    required String message,
  }) async {
    state = state.copyWith(
      isLoading: true,
      lastSubmittedMessage: message,
      userMessage: message,
      requestState: '질문 분석 중',
      answer: '질문을 분석하고 추천 후보를 찾는 중입니다.',
      clarificationType: null,
      suggestionType: null,
      moreMessage: null,
      suggestions: [],
      sources: [],
      cards: [],
      diagnostics: ['지역/조건을 구조화하고 추천 후보를 확인합니다.'],
    );
    try {
      final payload = await _handler.chat(
        apiBase: apiBase,
        message: message,
        sessionId: _sessionId,
      );
      final responseState = parseTourismChatResponse(payload);
      state = TourismChatState(
        requestState: responseState.requestState,
        answer: responseState.answer,
        isLoading: false,
        userMessage: message,
        lastSubmittedMessage: message,
        clarificationType: responseState.clarificationType,
        suggestionType: responseState.suggestionType,
        moreMessage: responseState.moreMessage,
        suggestions: responseState.suggestions,
        sources: responseState.sources,
        cards: responseState.cards,
        diagnostics: responseState.diagnostics,
      );
    } on TourismApiException catch (error) {
      state = TourismChatState(
        requestState: '오류 ${error.statusCode}',
        answer: error.message,
        userMessage: message,
        lastSubmittedMessage: message,
        sources: const [TourismSource(title: '오류가 해결되면 출처가 표시됩니다.')],
      );
    } on Object catch (error) {
      state = TourismChatState(
        requestState: '연결 실패',
        answer: '서버에 연결하지 못했습니다.\n$error',
        userMessage: message,
        lastSubmittedMessage: message,
        sources: const [TourismSource(title: '서버 연결 후 출처가 표시됩니다.')],
      );
    }
  }

  static String _createSessionId() =>
      'flutter-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}';
}
