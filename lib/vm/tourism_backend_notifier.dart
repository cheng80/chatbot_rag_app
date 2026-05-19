import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tourism_api_handler.dart';

final tourismBackendNotifierProvider =
    NotifierProvider<TourismBackendNotifier, TourismBackendState>(
      TourismBackendNotifier.new,
    );

class TourismBackendState {
  const TourismBackendState({
    this.isChecking = false,
    this.isOnline = false,
    this.statusText = '서버 미확인',
    this.capabilities = const [],
    this.errorMessage,
  });

  final bool isChecking;
  final bool isOnline;
  final String statusText;
  final List<String> capabilities;
  final String? errorMessage;

  TourismBackendState copyWith({
    bool? isChecking,
    bool? isOnline,
    String? statusText,
    List<String>? capabilities,
    String? errorMessage,
  }) {
    return TourismBackendState(
      isChecking: isChecking ?? this.isChecking,
      isOnline: isOnline ?? this.isOnline,
      statusText: statusText ?? this.statusText,
      capabilities: capabilities ?? this.capabilities,
      errorMessage: errorMessage,
    );
  }
}

/// FastAPI 서버가 ML·DL·외부 API 기능을 제공하는지 확인하는 ViewModel이다.
class TourismBackendNotifier extends Notifier<TourismBackendState> {
  late final TourismApiHandler _handler;

  @override
  TourismBackendState build() {
    _handler = TourismApiHandler();
    return const TourismBackendState();
  }

  Future<void> check(String apiBase) async {
    state = state.copyWith(isChecking: true, errorMessage: null);
    try {
      await _handler.health(apiBase);
      final regions = await _handler.fetchRegions(apiBase);
      state = TourismBackendState(
        isOnline: true,
        statusText: 'FastAPI 연결됨',
        capabilities: [
          'FastAPI /tourism/chat',
          'TourAPI 외부 API',
          'Ollama LLM 추론',
          'Chroma/RAG 검색',
          '서버 한국어 교정 모델',
          '서버 조건 Transformer 보조',
          '지역 ${regions.length}개 로드',
        ],
      );
    } on Object catch (error) {
      state = TourismBackendState(
        isOnline: false,
        statusText: '서버 연결 실패',
        errorMessage: '$error',
      );
    }
  }
}
