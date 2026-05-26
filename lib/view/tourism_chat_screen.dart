import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../vm/app_config.dart';
import '../vm/tourism_api_handler.dart';
import '../vm/tourism_chat_notifier.dart';
import '../vm/tourism_models.dart';
import '../vm/tourism_option_builder.dart';
import 'widgets/cards_panel.dart';
import 'widgets/common_widgets.dart';
import 'widgets/composer.dart';
import 'widgets/debug_panel.dart';
import 'widgets/help_sheet.dart';
import 'widgets/message_panels.dart';
import 'widgets/top_bar.dart';
import 'widgets/toast_banner.dart';

class TourismChatScreen extends ConsumerStatefulWidget {
  const TourismChatScreen({super.key});

  @override
  ConsumerState<TourismChatScreen> createState() => _TourismChatScreenState();
}

class _TourismChatScreenState extends ConsumerState<TourismChatScreen> {
  final _messageController = TextEditingController();
  final _apiBaseController = TextEditingController(text: AppConfig.apiBase);
  final _scrollController = ScrollController();
  final _apiHandler = TourismApiHandler();

  String _toast = '';
  String _inputMode = 'chat';
  String _chatDraft = '';
  String _area = '';
  String _sigungu = '';
  String _intensity = 'required';
  String _expansion = 'local_only';
  bool _showDebug = AppConfig.debugUi;
  bool _showFullAnswer = false;
  bool _optionManualEdit = false;
  String _optionGeneratedMessage = '';

  final Set<String> _conditions = {};
  final Set<String> _preferences = {};
  final Set<String> _exclusions = {};

  List<RegionOption> _regions = fallbackRegionOptions();

  @override
  void initState() {
    super.initState();
    _fetchRegions();
    _messageController.addListener(_trackManualOptionEdit);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _apiBaseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final layout = TourismLayoutMetrics.fromWidth(width);
    final chatState = ref.watch(tourismChatNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.appMaxWidth),
            child: Container(
              margin: EdgeInsets.all(layout.shellMargin),
              decoration: BoxDecoration(
                color: tourismChatColor,
                borderRadius: BorderRadius.circular(layout.isPhone ? 0 : 28),
                border: layout.isPhone
                    ? null
                    : Border.all(color: Colors.black.withValues(alpha: 0.08)),
                boxShadow: layout.isPhone
                    ? const []
                    : [
                        BoxShadow(
                          color: const Color(
                            0xff1f342a,
                          ).withValues(alpha: 0.14),
                          blurRadius: 34,
                          offset: const Offset(0, 18),
                        ),
                      ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  TopBar(
                    showDebug: _showDebug,
                    allowDebug: AppConfig.debugUi,
                    onDebugChanged: (value) => setState(() {
                      _showDebug = value;
                      ref
                          .read(tourismChatNotifierProvider.notifier)
                          .showDemo(value);
                    }),
                    onHelp: _openHelp,
                  ),
                  if (_showDebug)
                    DebugPanel(
                      apiBaseController: _apiBaseController,
                      state: chatState.requestState,
                      diagnostics: chatState.diagnostics,
                    ),
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: layout.viewportPadding,
                      children: [
                        const WarningBubble(),
                        if (chatState.liveUpdatePending)
                          LiveUpdateBanner(
                            onPressed: () => _submitSuggestion('최신 결과 업데이트 보기'),
                          ),
                        if (chatState.userMessage.isNotEmpty)
                          UserBubble(text: chatState.userMessage),
                        AnswerPanel(
                          answer: _visibleAnswer(chatState.answer),
                          canExpand:
                              chatState.answer.trim() !=
                              _compactAnswer(chatState.answer).trim(),
                          isExpanded: _showFullAnswer,
                          isLoading: chatState.isLoading,
                          clarificationType: chatState.clarificationType,
                          suggestionType: chatState.suggestionType,
                          suggestions: chatState.suggestions,
                          sources: chatState.sources,
                          onToggleAnswer: () => setState(
                            () => _showFullAnswer = !_showFullAnswer,
                          ),
                          onClear: _clear,
                          onSuggestion: _submitSuggestion,
                        ),
                        CardsPanel(
                          cards: chatState.cards,
                          cardCount: chatState.cards.length,
                          queryText: chatState.lastSubmittedMessage,
                          moreMessage: chatState.moreMessage,
                          onMore: _submitSuggestion,
                        ),
                      ],
                    ),
                  ),
                  Composer(
                    controller: _messageController,
                    inputMode: _inputMode,
                    isLoading: chatState.isLoading,
                    area: _area,
                    sigungu: _sigungu,
                    intensity: _intensity,
                    expansion: _expansion,
                    regions: _regions,
                    conditions: _conditions,
                    preferences: _preferences,
                    exclusions: _exclusions,
                    optionSummary: _optionSummary(),
                    onOpenOptions: _openOptions,
                    onRegionPrompt: _applyRegionPrompt,
                    onQuickPrompt: _applyQuickPrompt,
                    onSubmit: _submitCurrentMessage,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _toast.isEmpty
          ? null
          : ToastBanner(message: _toast),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _visibleAnswer(String answer) =>
      _showFullAnswer ? answer : _compactAnswer(answer);

  Future<void> _fetchRegions() async {
    try {
      final areas = await _apiHandler.fetchRegions(_normalizedApiBase());
      final fetched = areas
          .map(
            (area) => RegionOption(
              name: '${area['name'] ?? ''}'.trim(),
              sigungu: (area['sigungu'] as List? ?? [])
                  .map((value) => '$value'.trim())
                  .where((value) => value.isNotEmpty)
                  .toList(),
            ),
          )
          .where((area) => area.name.isNotEmpty)
          .toList();
      if (fetched.isNotEmpty && mounted) setState(() => _regions = fetched);
    } catch (_) {
      // 서버 연결이 없어도 선택형 지역 입력은 계속 사용할 수 있게 기본 목록을 유지한다.
    }
  }

  Future<void> _submitCurrentMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _showToast('질문을 입력해 주세요.');
      return;
    }

    setState(() {
      _showFullAnswer = false;
    });
    _scrollToResponseStart();

    await ref
        .read(tourismChatNotifierProvider.notifier)
        .submit(apiBase: _normalizedApiBase(), message: message);
    final chatState = ref.read(tourismChatNotifierProvider);
    if (chatState.cards.isNotEmpty) {
      _showToast('${chatState.cards.length}개의 추천 카드를 찾았습니다.');
    } else if (chatState.liveUpdatePending) {
      _showToast('최신 후보를 계속 확인하고 있습니다.');
    } else if (chatState.requestState.contains('오류')) {
      _showToast('요청 처리 중 문제가 발생했습니다.');
    } else if (chatState.requestState.contains('실패')) {
      _showToast('서버에 연결하지 못했습니다.');
    }
    _scrollToResponseStart();
  }

  void _clear() {
    setState(() {
      _toast = '';
      _inputMode = 'chat';
      _chatDraft = '';
      _area = '';
      _sigungu = '';
      _intensity = 'required';
      _expansion = 'local_only';
      _conditions.clear();
      _preferences.clear();
      _exclusions.clear();
      _messageController.clear();
      _optionGeneratedMessage = '';
      _optionManualEdit = false;
    });
    ref.read(tourismChatNotifierProvider.notifier).clear();
  }

  void _setInputMode(String mode) {
    if (mode == _inputMode) return;
    setState(() {
      if (_inputMode == 'chat') _chatDraft = _messageController.text;
      _inputMode = mode;
      if (mode == 'chat') {
        _messageController.text = _chatDraft;
      } else {
        _syncOptionMessage();
      }
    });
  }

  void _setOptionArea(String value) {
    setState(() {
      _area = value;
      _sigungu = '';
      _syncOptionMessage();
    });
  }

  void _toggleOption(Set<String> target, String value) {
    setState(() {
      if (!target.add(value)) target.remove(value);
      _syncOptionMessage();
    });
  }

  void _syncOptionMessage() {
    final message = buildOptionFlowMessage(
      area: _area,
      sigungu: _sigungu,
      conditions: _conditions.toList(),
      preferences: _preferences.toList(),
      exclusions: _exclusions.toList(),
      intensity: _intensity,
      expansion: _expansion,
    );
    final hasSignal =
        _area.isNotEmpty ||
        _sigungu.isNotEmpty ||
        _conditions.isNotEmpty ||
        _preferences.isNotEmpty ||
        _exclusions.isNotEmpty;
    final previous = _optionGeneratedMessage;
    _optionGeneratedMessage = hasSignal ? message : '';
    if (_inputMode == 'option' &&
        (!_optionManualEdit ||
            _messageController.text.trim().isEmpty ||
            _messageController.text.trim() == previous.trim())) {
      _messageController.text = _optionGeneratedMessage;
      _optionManualEdit = false;
    }
  }

  void _trackManualOptionEdit() {
    if (_inputMode == 'option') {
      _optionManualEdit =
          _messageController.text.trim() != _optionGeneratedMessage.trim();
    }
  }

  void _applyQuickPrompt(String prompt) {
    _setInputMode('chat');
    _messageController.text = prompt;
    _showToast('질문 예시를 입력했습니다.');
  }

  void _applyRegionPrompt(String region) {
    _setInputMode('chat');
    final condition = inferConditionText(_messageController.text);
    _messageController.text = '$region에서 $condition 관광지 추천해줘';
    _showToast('$region 기준으로 질문을 준비했습니다.');
  }

  void _submitSuggestion(String message) {
    _messageController.text = message;
    _submitCurrentMessage();
  }

  void _showToast(String message) {
    setState(() => _toast = message);
    Future<void>.delayed(const Duration(milliseconds: 2600), () {
      if (mounted && _toast == message) setState(() => _toast = '');
    });
  }

  void _scrollToResponseStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _openHelp() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const HelpSheet(),
    );
  }

  void _openOptions() {
    setState(() => _inputMode = 'option');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return OptionSheet(
          area: _area,
          sigungu: _sigungu,
          intensity: _intensity,
          expansion: _expansion,
          regions: _regions,
          conditions: _conditions,
          preferences: _preferences,
          exclusions: _exclusions,
          onAreaChanged: _setOptionArea,
          onSigunguChanged: (value) => setState(() {
            _sigungu = value;
            _syncOptionMessage();
          }),
          onIntensityChanged: (value) => setState(() {
            _intensity = value;
            _syncOptionMessage();
          }),
          onExpansionChanged: (value) => setState(() {
            _expansion = value;
            _syncOptionMessage();
          }),
          onToggleCondition: (value) => _toggleOption(_conditions, value),
          onTogglePreference: (value) => _toggleOption(_preferences, value),
          onToggleExclusion: (value) => _toggleOption(_exclusions, value),
        );
      },
    );
  }

  String _normalizedApiBase() =>
      AppConfig.normalizeApiBase(_apiBaseController.text);

  String _optionSummary() {
    final parts = [
      if (_area.isNotEmpty) _area,
      if (_sigungu.isNotEmpty) _sigungu,
      ..._conditions.take(2).map((key) => conditionLabels[key] ?? key),
      ..._preferences.take(1).map((key) => preferenceLabels[key] ?? key),
      ..._exclusions.take(1).map((key) => exclusionLabels[key] ?? key),
    ];
    return parts.isEmpty ? '조건 선택' : parts.join(' · ');
  }

  static String _compactAnswer(String text) {
    final normalized = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    if (normalized.length <= 150) return normalized;
    final firstParagraph =
        normalized
            .split(RegExp(r'\n{2,}'))
            .where((value) => value.isNotEmpty)
            .firstOrNull ??
        normalized;
    final sentences = firstParagraph
        .split(RegExp(r'(?<=[.!?。！？요다니다함됨세요])\s+'))
        .where((value) => value.isNotEmpty)
        .toList();
    final summary = sentences.take(2).join(' ').trim();
    if (summary.length >= 48 && summary.length <= 180) return summary;
    return '${firstParagraph.substring(0, min(150, firstParagraph.length)).trim()}...';
  }
}
