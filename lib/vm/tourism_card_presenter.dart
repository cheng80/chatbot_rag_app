import 'tourism_models.dart';

List<TourismSource> dedupeSources(List<TourismSource> sources) {
  final seen = <String>{};
  final result = <TourismSource>[];
  for (final source in sources) {
    final key = '${source.title}:${source.url ?? ''}';
    if (source.title.trim().isEmpty || !seen.add(key)) continue;
    result.add(source);
  }
  return result;
}

List<(String, String)> cardEvidenceHighlights(
  TourismCard card,
  String queryText,
) {
  final raw = card.rawFields;
  final accessibility = card.accessibility;
  final candidates = <(String, String?)>[
    ('휠체어', firstValue(accessibility['wheelchair'], raw['휠체어'], raw['출입통로'])),
    (
      '동선',
      firstValue(raw['접근로'], raw['출입통로'], accessibility['route'], raw['대중교통']),
    ),
    ('화장실', firstValue(accessibility['restroom'], raw['화장실'])),
    ('주차', firstValue(raw['주차'], accessibility['parking'])),
    ('승강', firstValue(accessibility['elevator'], raw['엘리베이터'])),
    (
      '수어/자막',
      firstValue(raw['수어안내'], raw['자막/영상안내'], raw['청각장애'], raw['안내시설']),
    ),
    (
      '점자/촉지',
      firstValue(raw['점자블록'], raw['점자홍보물'], raw['안내시스템'], raw['시각장애 기타']),
    ),
    (
      '유아',
      firstValue(
        accessibility['stroller'],
        accessibility['nursing_room'],
        raw['유모차'],
        raw['수유실'],
        raw['유아용 의자'],
      ),
    ),
    ('대중교통', raw['대중교통']),
    ('보조견', raw['보조견']),
  ];
  final result = <(String, String)>[];
  final seen = <String>{};
  for (final item in candidates) {
    final value = normalizeDisplayText(item.$2);
    if (value.isEmpty || !seen.add(value.replaceAll(RegExp(r'\s+'), ''))) {
      continue;
    }
    result.add((item.$1, value));
  }
  for (final tag in [...card.accessibilityTags, ...card.familyTags]) {
    final label = conditionLabelFromTag(tag);
    if (label.isEmpty || result.any((item) => item.$1 == label)) continue;
    result.add((label, fallbackEvidenceText(label, tag)));
  }
  return result.take(6).toList();
}

String? firstValue(String? a, [String? b, String? c, String? d, String? e]) {
  for (final value in [a, b, c, d, e]) {
    if (value != null && value.trim().isNotEmpty) return value;
  }
  return null;
}

List<(String, String)> rawDetailEntries(TourismCard card) {
  const labels = {
    'parking': '주차',
    'route': '접근로',
    'publictransport': '대중교통',
    'ticketoffice': '매표소',
    'promotion': '홍보물',
    'wheelchair': '휠체어',
    'exit': '출입통로',
    'elevator': '엘리베이터',
    'restroom': '화장실',
    'auditorium': '관람석',
    'room': '객실',
    'handicapetc': '장애인 기타',
    'braileblock': '점자블록',
    'helpdog': '보조견',
    'guidehuman': '안내요원',
    'audioguide': '오디오가이드',
    'bigprint': '큰활자',
    'brailepromotion': '점자홍보물',
    'guidesystem': '안내시스템',
    'blindhandicapetc': '시각장애 기타',
    'signguide': '수어안내',
    'videoguide': '자막/영상안내',
    'hearingroom': '청각장애 객실',
    'hearinghandicapetc': '청각장애 기타',
    'stroller': '유모차',
    'lactationroom': '수유실',
    'babysparechair': '유아용 의자',
    'infantsfamilyetc': '영유아 기타',
  };
  final rows = <(String, String)>[];
  final seen = <String>{};
  for (final entry in card.rawFields.entries) {
    if (entry.value.isEmpty) continue;
    final label = labels[entry.key] ?? entry.key;
    rows.add((label, normalizeDisplayText(entry.value)));
    seen.add(label);
  }
  for (final entry in card.accessibility.entries) {
    final label = accessibilityLabels[entry.key] ?? entry.key;
    if (entry.value.isEmpty || seen.contains(label)) continue;
    rows.add((label, normalizeDisplayText(entry.value)));
  }
  return rows;
}

const accessibilityLabels = {
  'wheelchair': '휠체어',
  'parking': '주차',
  'restroom': '화장실',
  'stroller': '유아차',
  'nursing_room': '수유실',
  'elevator': '엘리베이터',
  'route': '동선',
};

String conditionLabelFromTag(String tag) {
  if (RegExp('휠체어|접근|무장애').hasMatch(tag)) return '휠체어';
  if (RegExp('동선|경사|통로|턱|접근로').hasMatch(tag)) return '동선';
  if (tag.contains('화장실')) return '화장실';
  if (tag.contains('주차')) return '주차';
  if (RegExp('엘리베이터|승강').hasMatch(tag)) return '승강';
  if (RegExp('대중교통|버스|지하철').hasMatch(tag)) return '대중교통';
  if (RegExp('점자|촉지|시각|오디오|음성').hasMatch(tag)) return '점자/촉지';
  if (RegExp('수어|수화|자막|청각|문자').hasMatch(tag)) return '수어/자막';
  if (RegExp('보조견|안내견').hasMatch(tag)) return '보조견';
  if (RegExp('유아|영유아|가족|수유|유모차|유아차|기저귀').hasMatch(tag)) return '유아';
  return tag.length <= 8 ? tag : '';
}

String fallbackEvidenceText(String label, String tag) {
  const suffix = '상세 위치와 이용 가능 여부는 방문 전 확인해 주세요.';
  if (label == tag) return suffix;
  return '$tag 기준에 맞는 후보입니다. $suffix';
}
