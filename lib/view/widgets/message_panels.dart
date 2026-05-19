import 'package:flutter/material.dart';

import '../../vm/tourism_chat_state.dart';
import '../../vm/tourism_models.dart';
import 'common_widgets.dart';

class WarningBubble extends StatelessWidget {
  const WarningBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return const TourismPanel(
      color: Color(0xfffff3c9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '방문 전 확인 필요',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xff755900),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '운영 시간, 휠체어 동선, 주차, 화장실 정보는 방문 전 공식 안내·전화·현장 정보로 다시 확인해 주세요.',
            style: TextStyle(color: Color(0xff755900), height: 1.45),
          ),
        ],
      ),
    );
  }
}

class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TourismAnimatedEntrance(
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 11),
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xffbdebd2),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.5),
          ),
        ),
      ),
    );
  }
}

class AnswerPanel extends StatelessWidget {
  const AnswerPanel({
    super.key,
    required this.answer,
    required this.canExpand,
    required this.isExpanded,
    required this.isLoading,
    required this.clarificationType,
    required this.suggestionType,
    required this.suggestions,
    required this.sources,
    required this.onToggleAnswer,
    required this.onClear,
    required this.onSuggestion,
  });

  final String answer;
  final bool canExpand;
  final bool isExpanded;
  final bool isLoading;
  final String? clarificationType;
  final String? suggestionType;
  final List<String> suggestions;
  final List<TourismSource> sources;
  final VoidCallback onToggleAnswer;
  final VoidCallback onClear;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return TourismPanel(
      child: AnimatedSize(
        duration: tourismMotionDuration,
        curve: tourismMotionCurve,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '답변',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ),
                if (canExpand)
                  TextButton(
                    onPressed: onToggleAnswer,
                    child: Text(isExpanded ? '접기' : '전체 보기'),
                  ),
                TextButton(onPressed: onClear, child: const Text('비우기')),
              ],
            ),
            AnimatedSwitcher(
              duration: tourismMotionDuration,
              switchInCurve: tourismMotionCurve,
              switchOutCurve: Curves.easeInCubic,
              child: clarificationType == null
                  ? const SizedBox.shrink(key: ValueKey('no-clarification'))
                  : Padding(
                      key: ValueKey(clarificationType),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ClarificationBanner(type: clarificationType!),
                    ),
            ),
            AnimatedSwitcher(
              duration: tourismMotionDuration,
              switchInCurve: tourismMotionCurve,
              switchOutCurve: Curves.easeInCubic,
              child: Text(
                answer,
                key: ValueKey(answer),
                style: const TextStyle(height: 1.62),
              ),
            ),
            AnimatedSwitcher(
              duration: tourismMotionDuration,
              child: isLoading
                  ? const Padding(
                      key: ValueKey('loading'),
                      padding: EdgeInsets.only(top: 10),
                      child: LinearProgressIndicator(minHeight: 4),
                    )
                  : const SizedBox.shrink(key: ValueKey('not-loading')),
            ),
            AnimatedSwitcher(
              duration: tourismMotionDuration,
              child: suggestions.isEmpty
                  ? const SizedBox.shrink(key: ValueKey('no-suggestions'))
                  : Padding(
                      key: ValueKey(suggestions.join('|')),
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: _suggestionChips(
                          suggestions,
                          suggestionType,
                          onSuggestion,
                        ),
                      ),
                    ),
            ),
            const Divider(height: 26),
            const Text('출처', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: tourismMotionDuration,
              child: Wrap(
                key: ValueKey(sources.map((source) => source.title).join('|')),
                spacing: 7,
                runSpacing: 7,
                children: sources.isEmpty
                    ? const [
                        TourismPill(text: '응답 후 한국관광공사 자료와 카드별 출처가 표시됩니다.'),
                      ]
                    : sources
                          .take(6)
                          .map((source) => SourcePill(source: source))
                          .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _suggestionChips(
  List<String> suggestions,
  String? suggestionType,
  ValueChanged<String> onSuggestion,
) {
  final labels = <String>{};
  final result = <Widget>[];
  for (final message in suggestions) {
    final label = suggestionButtonLabel(message, suggestionType);
    if (!labels.add(label)) continue;
    result.add(
      ActionChip(
        label: Text(label),
        tooltip: label == message ? null : message,
        onPressed: () => onSuggestion(message),
      ),
    );
  }
  return result;
}

class ClarificationBanner extends StatelessWidget {
  const ClarificationBanner({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final copy = switch (type) {
      'condition' => (
        '조건 확인 필요',
        '의미가 겹치는 접근성 표현입니다. 원하는 기준을 선택하면 그 조건으로 다시 조회합니다.',
      ),
      'region' => (
        '지역 선택 필요',
        '같은 이름의 지역이 여러 곳에 있습니다. 지역 후보를 선택하면 원래 질문 맥락을 유지해 다시 조회합니다.',
      ),
      _ => ('추가 질문 필요', '아래 후보를 선택하면 원래 질문 맥락을 유지한 채 다시 조회합니다.'),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xfffff3c9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x55755900)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.$1,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xff755900),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            copy.$2,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xff755900),
            ),
          ),
        ],
      ),
    );
  }
}
