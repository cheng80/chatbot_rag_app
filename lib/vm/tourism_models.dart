class RegionOption {
  const RegionOption({required this.name, required this.sigungu});

  final String name;
  final List<String> sigungu;
}

class TourismSource {
  const TourismSource({required this.title, this.url});

  factory TourismSource.fromJson(Map source) {
    return TourismSource(
      title:
          '${source['title'] ?? source['source'] ?? source['name'] ?? '검색 문서'}',
      url: usableSourceUrl('${source['url'] ?? source['source_url'] ?? ''}'),
    );
  }

  final String title;
  final String? url;
}

class TourismCard {
  const TourismCard({
    required this.contentId,
    required this.title,
    required this.address,
    required this.reason,
    required this.sourceName,
    required this.sourceUrl,
    required this.imageUrl,
    required this.tel,
    required this.mapX,
    required this.mapY,
    required this.accessibility,
    required this.rawFields,
    required this.accessibilityTags,
    required this.familyTags,
  });

  factory TourismCard.fromJson(Map card) {
    return TourismCard(
      contentId: '${card['content_id'] ?? ''}',
      title: '${card['title'] ?? ''}',
      address: '${card['address'] ?? ''}',
      reason: '${card['recommendation_reason'] ?? ''}',
      sourceName: '${card['source_name'] ?? '한국관광공사 무장애 여행 정보'}',
      sourceUrl: usableSourceUrl('${card['source_url'] ?? ''}') ?? '',
      imageUrl: '${card['image_url'] ?? ''}',
      tel: '${card['tel'] ?? ''}',
      mapX: _optionalDouble(card['map_x'] ?? card['mapx']),
      mapY: _optionalDouble(card['map_y'] ?? card['mapy']),
      accessibility: _stringMap(card['accessibility']),
      rawFields: _stringMap(card['raw_fields']),
      accessibilityTags: (card['accessibility_tags'] as List? ?? [])
          .map((value) => '$value')
          .toList(),
      familyTags: (card['family_tags'] as List? ?? [])
          .map((value) => '$value')
          .toList(),
    );
  }

  final String contentId;
  final String title;
  final String address;
  final String reason;
  final String sourceName;
  final String sourceUrl;
  final String imageUrl;
  final String tel;
  final double? mapX;
  final double? mapY;
  final Map<String, String> accessibility;
  final Map<String, String> rawFields;
  final List<String> accessibilityTags;
  final List<String> familyTags;

  static List<TourismCard> demoCards() {
    return [
      const TourismCard(
        contentId: 'demo-seonjeongneung',
        title: '서울 선릉과 정릉',
        address: '서울특별시 강남구 선릉로100길 1',
        reason: '도심 접근성이 좋고 산책 동선이 비교적 단순해 보호자와 함께 이동 계획을 세우기 좋습니다.',
        sourceName: '한국관광공사 무장애 여행 정보',
        sourceUrl: '',
        imageUrl: '',
        tel: '',
        mapX: 127.048272,
        mapY: 37.508818,
        accessibility: {
          'wheelchair': '일부 구간은 현장 경사와 노면 상태 확인 필요',
          'parking': '방문 전 장애인 주차 가능 여부 확인 필요',
          'restroom': '현장 안내 확인 필요',
        },
        rawFields: {},
        accessibilityTags: ['휠체어 동선 확인', '주차 확인'],
        familyTags: ['가족 산책'],
      ),
      const TourismCard(
        contentId: 'demo-coex-aquarium',
        title: '코엑스 아쿠아리움',
        address: '서울특별시 강남구 영동대로 513',
        reason: '실내 이동 중심이라 날씨 영향을 줄일 수 있고, 가족 동반 시 관람 흐름을 설명하기 쉽습니다.',
        sourceName: '한국관광공사 무장애 여행 정보',
        sourceUrl: '',
        imageUrl: '',
        tel: '',
        mapX: 127.059159,
        mapY: 37.511823,
        accessibility: {
          'elevator': '건물 내 승강 설비 동선 확인 필요',
          'restroom': '편의시설 위치 확인 필요',
          'route': '혼잡 시간대 우회 동선 확인 권장',
        },
        rawFields: {},
        accessibilityTags: ['실내', '엘리베이터 확인'],
        familyTags: ['아이 동반'],
      ),
    ];
  }
}

double? _optionalDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value'.trim());
}

Map<String, String> _stringMap(Object? value) {
  if (value is! Map) return {};
  return value.map(
    (key, value) => MapEntry('$key', normalizeDisplayText(value)),
  );
}

List<RegionOption> fallbackRegionOptions() {
  return const [
    RegionOption(
      name: '서울',
      sigungu: [
        '강남구',
        '강동구',
        '강북구',
        '강서구',
        '관악구',
        '광진구',
        '구로구',
        '금천구',
        '노원구',
        '도봉구',
        '동대문구',
        '동작구',
        '마포구',
        '서대문구',
        '서초구',
        '성동구',
        '성북구',
        '송파구',
        '양천구',
        '영등포구',
        '용산구',
        '은평구',
        '종로구',
        '중구',
        '중랑구',
      ],
    ),
    RegionOption(
      name: '부산',
      sigungu: [
        '강서구',
        '금정구',
        '기장군',
        '남구',
        '동구',
        '동래구',
        '부산진구',
        '북구',
        '사상구',
        '사하구',
        '서구',
        '수영구',
        '연제구',
        '영도구',
        '중구',
        '해운대구',
      ],
    ),
    RegionOption(
      name: '인천',
      sigungu: [
        '강화군',
        '계양구',
        '미추홀구',
        '남동구',
        '동구',
        '부평구',
        '서구',
        '연수구',
        '옹진군',
        '중구',
      ],
    ),
    RegionOption(name: '대전', sigungu: ['대덕구', '동구', '서구', '유성구', '중구']),
    RegionOption(
      name: '대구',
      sigungu: ['남구', '달서구', '달성군', '동구', '북구', '서구', '수성구', '중구', '군위군'],
    ),
    RegionOption(name: '광주', sigungu: ['광산구', '남구', '동구', '북구', '서구']),
    RegionOption(name: '울산', sigungu: ['중구', '남구', '동구', '북구', '울주군']),
    RegionOption(name: '세종', sigungu: ['세종특별자치시']),
    RegionOption(name: '제주', sigungu: ['제주시', '서귀포시', '북제주군', '남제주군']),
  ];
}

String normalizeDisplayText(Object? value) {
  return '${value ?? ''}'
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String publicSourceName(String sourceName) =>
    sourceName.replaceAll(' OpenAPI', '');

String? usableSourceUrl(String url) {
  if (url.trim().isEmpty) return null;
  final parsed = Uri.tryParse(url);
  if (parsed == null || !parsed.hasScheme) {
    return null;
  }
  if (parsed.host == 'access.visitkorea.or.kr' &&
      parsed.path.startsWith('/detail/')) {
    return null;
  }
  return parsed.toString();
}
