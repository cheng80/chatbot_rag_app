const conditionLabels = {
  'wheelchair': '휠체어 이용',
  'stroller': '유모차/영유아',
  'senior': '어르신/보행 부담',
  'braille': '시각장애 접근성',
  'sign': '청각장애 접근성',
  'guide_dog': '안내견 동반',
};

const accessLabels = {
  'route': '입구/동선 접근로',
  'restroom': '장애인 화장실',
  'parking': '장애인 주차',
  'elevator': '엘리베이터/승강',
  'transit': '대중교통 접근',
  'audio': '오디오/음성 안내',
  'caption': '자막/문자 안내',
  'nursing': '수유실',
  'changing': '기저귀 교환대',
};

const optionConditionText = {
  'wheelchair': '휠체어 접근',
  'route': '입구/동선 접근로',
  'restroom': '장애인 화장실',
  'parking': '장애인 주차',
  'elevator': '엘리베이터',
  'transit': '대중교통 접근',
  'braille': '점자 안내',
  'audio': '음성 안내',
  'sign': '수어 안내',
  'caption': '자막 안내',
  'nursing': '수유실',
  'changing': '기저귀 교환대',
  'stroller': '유모차',
  'senior': '어르신 이동 부담',
  'guide_dog': '안내견 동반',
};

const preferenceLabels = {
  'indoor': '실내',
  'quiet': '조용한 곳',
  'park': '공원/산책',
  'museum': '박물관/전시',
};

const optionPreferenceText = {
  'indoor': '실내',
  'quiet': '조용한',
  'park': '공원이나 산책하기 좋은',
  'museum': '박물관이나 전시',
};

const exclusionLabels = {
  'market': '시장 제외',
  'food': '음식점/카페 제외',
  'lodging': '숙박 제외',
  'long_walk': '오래 걷는 코스 제외',
};

const optionExclusionText = {
  'market': '시장은 제외',
  'food': '음식점과 카페는 제외',
  'lodging': '숙박은 제외',
  'long_walk': '오래 걷는 코스는 제외',
};

const quickPrompts = [
  ('강남구 휠체어', '서울 강남구에서 휠체어 관광지 추천해줘'),
  ('강남구 근처', '서울 강남구 근처에서 휠체어 관광지 추천해줘'),
  ('중구 추가질문', '중구에서 휠체어 타시는 아버지와 갈 관광지 추천'),
  ('좌동 법정동', '해운대 좌동에서 유모차로 갈만한 관광지 추천'),
  ('일반구 매칭', '창원 마산합포구에서 이동약자 관광지 추천'),
  ('복합 조건', '서울에서 휠체어 타는 아버지와 아이가 비 오면 이동하기 편한 실내 관광지 추천'),
  ('서울 유아차', '서울에서 유아차로 가기 좋은 관광지 추천해줘'),
  ('부산 가족', '부산에서 가족과 가기 좋은 무장애 관광지 추천해줘'),
  ('제주 휠체어', '제주에서 휠체어 접근 가능한 관광지 추천해줘'),
];

String buildOptionFlowMessage({
  required String area,
  required String sigungu,
  required List<String> conditions,
  required List<String> preferences,
  required List<String> exclusions,
  required String intensity,
  required String expansion,
}) {
  final regionText = [
    area.trim(),
    sigungu.trim(),
  ].where((value) => value.isNotEmpty).join(' ');
  final conditionTexts = conditions
      .map((key) => optionConditionText[key])
      .nonNulls
      .toList();
  final preferenceTexts = preferences
      .map((key) => optionPreferenceText[key])
      .nonNulls
      .toList();
  final exclusionTexts = exclusions
      .map((key) => optionExclusionText[key])
      .nonNulls
      .toList();
  final baseRegion = regionText.isEmpty ? '선택한 지역' : regionText;
  var focusText = conditionTexts.isEmpty
      ? '무장애'
      : conditionPhrase(conditionTexts, intensity);
  if (preferenceTexts.isNotEmpty) {
    focusText = '${preferenceTexts.join(', ')} $focusText';
  }

  final chunks = <String>[];
  if (expansion == 'local_only' && sigungu.isNotEmpty) {
    chunks.add('$baseRegion 안에서 $focusText 관광지 추천해줘');
  } else {
    chunks.add('$baseRegion에서 $focusText 관광지 추천해줘');
  }
  if (exclusionTexts.isNotEmpty) {
    chunks.add('${exclusionTexts.join(', ')}해줘');
  }
  if (expansion == 'conditional' && area.isNotEmpty && sigungu.isNotEmpty) {
    chunks.add('부족하면 $area 전체로 넓혀줘');
  }
  if (expansion == 'area_now' && area.isNotEmpty) {
    chunks.add('$area 전체로 넓혀서 보여줘');
  }
  return chunks.join('. ').replaceAll(RegExp(r'\s+'), ' ').trim();
}

String conditionPhrase(List<String> conditionTexts, String intensity) {
  final joined = joinKoreanList(conditionTexts);
  if (intensity == 'optional') return '$joined 있으면 좋은';
  if (conditionTexts.length >= 2) return '$joined 모두 있는';
  return '$joined 가능한';
}

String joinKoreanList(List<String> items) {
  if (items.length <= 1) return items.firstOrNull ?? '';
  if (items.length == 2) {
    return '${items[0]}${koreanAndParticle(items[0])} ${items[1]}';
  }
  return '${items.take(items.length - 1).join(', ')}와 ${items.last}';
}

String koreanAndParticle(String text) {
  if (text.trim().isEmpty) return '와';
  final code = text.trim().runes.last;
  if (code < 0xac00 || code > 0xd7a3) return '와';
  return (code - 0xac00) % 28 == 0 ? '와' : '과';
}

String inferConditionText(String message) {
  if (message.contains('유아차') ||
      message.contains('아이') ||
      message.contains('가족')) {
    return '유아차 가족';
  }
  if (message.contains('고령자') ||
      message.contains('어르신') ||
      message.contains('노인')) {
    return '휠체어 고령자';
  }
  if (message.contains('휠체어') || message.contains('장애인')) return '휠체어';
  return '무장애';
}
