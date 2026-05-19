import 'tourism_card_presenter.dart';
import 'tourism_models.dart';

class TourismChatState {
  const TourismChatState({
    required this.answer,
    this.userMessage = '',
    this.requestState = '대기 중',
    this.lastSubmittedMessage = '',
    this.clarificationType,
    this.suggestionType,
    this.moreMessage,
    this.isLoading = false,
    this.suggestions = const [],
    this.sources = const [],
    this.cards = const [],
    this.diagnostics = const [],
  });

  final String answer;
  final String userMessage;
  final String requestState;
  final String lastSubmittedMessage;
  final String? clarificationType;
  final String? suggestionType;
  final String? moreMessage;
  final bool isLoading;
  final List<String> suggestions;
  final List<TourismSource> sources;
  final List<TourismCard> cards;
  final List<String> diagnostics;

  factory TourismChatState.demo(bool showDebug) {
    if (!showDebug) {
      return const TourismChatState(
        answer: '가고 싶은 지역과 동행 조건을 알려주세요. 추천 가능한 장소를 카드로 정리해 드립니다.',
        sources: [TourismSource(title: '응답 후 한국관광공사 자료와 카드별 출처가 표시됩니다.')],
      );
    }
    return TourismChatState(
      requestState: '시연 예시',
      diagnostics: const ['지역 선택, 추천 카드, 출처, 경고 문구가 보이도록 구성한 초기 예시입니다.'],
      answer:
          '시연 예시입니다. 지역을 선택하거나 질문을 보내면 실제 /tourism/chat 응답으로 교체됩니다.\n\n서울 강남구 기준으로 휠체어 접근성, 주차, 화장실 확인이 필요한 관광지를 카드 형태로 보여줍니다.',
      sources: const [
        TourismSource(title: '예시 출처: 한국관광공사 무장애 여행 정보'),
        TourismSource(title: '실제 응답 후 카드별 원문 링크가 표시됩니다.'),
      ],
      cards: TourismCard.demoCards(),
    );
  }

  TourismChatState copyWith({
    String? answer,
    String? userMessage,
    String? requestState,
    String? lastSubmittedMessage,
    String? clarificationType,
    String? suggestionType,
    String? moreMessage,
    bool? isLoading,
    List<String>? suggestions,
    List<TourismSource>? sources,
    List<TourismCard>? cards,
    List<String>? diagnostics,
  }) {
    return TourismChatState(
      answer: answer ?? this.answer,
      userMessage: userMessage ?? this.userMessage,
      requestState: requestState ?? this.requestState,
      lastSubmittedMessage: lastSubmittedMessage ?? this.lastSubmittedMessage,
      clarificationType: clarificationType,
      suggestionType: suggestionType,
      moreMessage: moreMessage,
      isLoading: isLoading ?? this.isLoading,
      suggestions: suggestions ?? this.suggestions,
      sources: sources ?? this.sources,
      cards: cards ?? this.cards,
      diagnostics: diagnostics ?? this.diagnostics,
    );
  }
}

TourismChatState parseTourismChatResponse(Map<String, dynamic> payload) {
  final cards = (payload['cards'] as List? ?? [])
      .whereType<Map>()
      .map(TourismCard.fromJson)
      .toList();
  final mode = '${payload['lookup_mode'] ?? 'unknown'}';
  final degraded = payload['degraded'] == true;
  final sources = (payload['sources'] as List? ?? [])
      .whereType<Map>()
      .map(TourismSource.fromJson)
      .toList();
  final cardSources = cards
      .map(
        (card) => TourismSource(
          title: publicSourceName(card.sourceName),
          url: usableSourceUrl(card.sourceUrl),
        ),
      )
      .toList();
  final suggestions = (payload['suggested_messages'] as List? ?? [])
      .map((value) => '$value')
      .where((value) => value.trim().isNotEmpty)
      .toList();
  final clarificationType = mode == 'clarification'
      ? inferClarificationType(payload)
      : null;
  final suggestionType =
      clarificationType ?? inferSuggestionType(payload, cards, suggestions);
  final moreMessage = suggestions
      .where((message) => RegExp('더 보기|전부|20곳').hasMatch(message))
      .firstOrNull;
  final diagnostics = <String>[_modeDescription(mode)];
  if (degraded) diagnostics.add('일부 자료 확인이 원활하지 않아 준비된 자료로 먼저 안내했습니다.');
  if (payload['reasoning_assist_used'] == true) {
    diagnostics.add('복합 조건을 반영하기 위해 추론 보조로 후보 순서를 조정했습니다.');
  }
  final reasoningNotes = payload['reasoning_assist_notes'];
  if (reasoningNotes is List) {
    diagnostics.addAll(reasoningNotes.map((note) => '추론 보조 메모: $note'));
  }
  final warnings = payload['warnings'];
  if (warnings is List) {
    diagnostics.addAll(warnings.map((warning) => '$warning'));
  }
  final dedupedSources = dedupeSources([...sources, ...cardSources]);

  return TourismChatState(
    requestState: _modeLabel(mode, degraded),
    answer: '${payload['answer'] ?? '답변 문장이 비어 있습니다.'}',
    clarificationType: clarificationType,
    suggestionType: suggestionType,
    moreMessage: moreMessage,
    suggestions: suggestions,
    sources: dedupedSources.isEmpty
        ? const [TourismSource(title: '출처 정보가 비어 있습니다. 카드별 출처를 확인하세요.')]
        : dedupedSources,
    cards: cards,
    diagnostics: diagnostics,
  );
}

String inferClarificationType(Map<String, dynamic> payload) {
  final answer = '${payload['answer'] ?? ''}';
  final messages = (payload['suggested_messages'] as List? ?? []).join(' ');
  final joined = '$answer $messages';
  if (RegExp(
    '접근성 의미|어르신 이동 부담|입구/동선 접근로|휠체어 접근|대중교통 접근|장애인 화장실',
  ).hasMatch(joined)) {
    return 'condition';
  }
  if (RegExp('어느 지역|여러 시도|지역이 여러|서울 중구|부산 중구|인천 중구').hasMatch(joined)) {
    return 'region';
  }
  return 'general';
}

String? inferSuggestionType(
  Map<String, dynamic> payload,
  List<TourismCard> cards,
  List<String> messages,
) {
  final mode = '${payload['lookup_mode'] ?? 'unknown'}';
  if ((mode == 'unknown' || mode == 'sample') &&
      cards.isEmpty &&
      messages.isNotEmpty) {
    return 'shortage';
  }
  if (messages.any((message) => RegExp('전체로 넓혀|범위.*넓혀').hasMatch(message))) {
    return 'expansion';
  }
  return null;
}

String suggestionButtonLabel(String message, [String? suggestionType]) {
  if (suggestionType == 'shortage') {
    if (RegExp('전체로 넓혀|범위|전체').hasMatch(message)) return '같은 시·도까지 넓히기';
    if (message.contains('무장애 관광지')) return '조건 완화하기';
    return '이 조건으로 다시 찾기';
  }
  if (suggestionType == 'expansion' &&
      RegExp('전체로 넓혀|범위.*넓혀').hasMatch(message)) {
    return '같은 시·도까지 넓혀 보기';
  }
  if (suggestionType == 'condition') {
    const labels = [
      '휠체어 접근',
      '입구/동선 접근로',
      '어르신 이동 부담 적은 곳',
      '장애인 화장실',
      '대중교통 접근',
    ];
    return labels.firstWhere(
      (label) => message.contains(label),
      orElse: () => message,
    );
  }
  if (RegExp('전체로 넓혀|범위|전체').hasMatch(message)) return '같은 시·도까지 넓혀 보기';
  if (message.contains('무장애 관광지')) return '조건 완화하기';
  return message;
}

String _modeLabel(String mode, bool degraded) {
  if (mode == 'live') return 'Live API 응답';
  if (mode == 'live_top_up') return 'Live 보강 응답';
  if (mode == 'cache') return 'Live 캐시 응답';
  if (mode == 'indexed') return degraded ? '색인 fallback' : '색인 응답';
  if (mode == 'sample') return '샘플 fallback';
  if (mode == 'clarification') return '추가 확인 필요';
  if (mode == 'unsupported') return '지원 범위 밖';
  return degraded ? 'Fallback 응답' : '정상 응답';
}

String _modeDescription(String mode) {
  if (mode == 'live') return '지역이 확정되어 TourAPI 후보와 접근성 상세를 live로 조회했습니다.';
  if (mode == 'live_top_up') return '저장된 후보에 live TourAPI 조회 후보를 보강했습니다.';
  if (mode == 'cache') {
    return '이전에 live 조회해 저장한 Markdown 캐시에서 같은 지역 관광 카드를 찾았습니다.';
  }
  if (mode == 'indexed') return 'live 결과 대신 Chroma 색인에서 관광 카드 문서를 찾았습니다.';
  if (mode == 'sample') return 'API/색인 결과 대신 서버 fallback 샘플을 사용했습니다.';
  if (mode == 'clarification') return '추천 전에 지역 또는 접근성 기준 확인이 필요합니다.';
  if (mode == 'unsupported') return '현재 MVP 범위를 벗어난 질문이라 관광지 카드를 만들지 않았습니다.';
  return '응답 생성 경로를 확인하지 못했습니다.';
}
