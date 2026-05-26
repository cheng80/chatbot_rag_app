import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatbot_rag_app/app.dart';
import 'package:chatbot_rag_app/vm/app_config.dart';
import 'package:chatbot_rag_app/vm/tourism_models.dart';
import 'package:chatbot_rag_app/view/widgets/cards_panel.dart';
import 'package:chatbot_rag_app/view/widgets/message_panels.dart';
import 'package:chatbot_rag_app/vm/tourism_option_builder.dart';
import 'package:chatbot_rag_app/view/widgets/common_widgets.dart';

void main() {
  testWidgets('renders tourism chat app on mobile and tablet viewports', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final devices = <String, Size>{
      'iPhone': const Size(393, 852),
      'Android phone': const Size(412, 915),
      'iPad': const Size(820, 1180),
      'Android tablet': const Size(800, 1280),
    };

    for (final entry in devices.entries) {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(const ProviderScope(child: TourismChatApp()));
      await tester.pump();

      expect(find.text('무장애 관광 상담'), findsOneWidget, reason: entry.key);
      expect(
        find.text('조건에 맞는 관광지를 카드로 추천합니다.'),
        findsOneWidget,
        reason: entry.key,
      );
      expect(find.text('답변'), findsOneWidget, reason: entry.key);
      expect(
        find.text('추천 카드', skipOffstage: false),
        findsOneWidget,
        reason: entry.key,
      );
      expect(find.byIcon(Icons.send), findsOneWidget, reason: entry.key);

      await tester.tap(find.text('조건 선택').last);
      await tester.pumpAndSettle();

      expect(find.text('광역 지역'), findsOneWidget, reason: entry.key);
      expect(find.text('접근성 조건'), findsOneWidget, reason: entry.key);

      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();
    }
  });

  test('layout metrics classify mobile and tablet targets', () {
    expect(
      TourismLayoutMetrics.fromWidth(393).deviceClass,
      TourismDeviceClass.phone,
    );
    expect(
      TourismLayoutMetrics.fromWidth(820).deviceClass,
      TourismDeviceClass.tablet,
    );
    expect(TourismLayoutMetrics.fromWidth(820).contentMaxWidth, 720);
    expect(TourismLayoutMetrics.fromWidth(393).cardMediaHeight, 132);
  });

  testWidgets('card image opens original photo dialog and closes it', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;

    const card = TourismCard(
      contentId: 'test-card',
      title: '테스트 장소',
      address: '서울특별시 테스트구',
      reason: '사진 확인 동작 테스트',
      sourceName: '한국관광공사 무장애 여행 정보',
      sourceUrl: '',
      imageUrl: 'https://example.com/photo.jpg',
      tel: '',
      mapX: null,
      mapY: null,
      accessibility: {},
      rawFields: {},
      accessibilityTags: [],
      familyTags: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlaceCard(card: card, queryText: ''),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CardImagePreview), findsOneWidget);

    await tester.tap(find.byType(CardImagePreview));
    await tester.pumpAndSettle();

    expect(find.byTooltip('사진 닫기'), findsOneWidget);
    expect(find.text('원본'), findsOneWidget);

    await tester.tapAt(const Offset(16, 16));
    await tester.pumpAndSettle();
    expect(find.byTooltip('사진 닫기'), findsNothing);

    await tester.tap(find.byType(CardImagePreview));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('사진 닫기'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('사진 닫기'), findsNothing);
  });

  testWidgets('map button uses a monochrome material icon', (tester) async {
    const card = TourismCard(
      contentId: 'test-map-card',
      title: '지도 장소',
      address: '서울특별시 테스트구',
      reason: '지도 버튼 테스트',
      sourceName: '한국관광공사 무장애 여행 정보',
      sourceUrl: '',
      imageUrl: '',
      tel: '',
      mapX: 127.0,
      mapY: 37.0,
      accessibility: {},
      rawFields: {},
      accessibilityTags: [],
      familyTags: [],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlaceCard(card: card, queryText: ''),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('지도 보기'), findsOneWidget);
    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
  });

  testWidgets('live update banner exposes a latest-result action', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: LiveUpdateBanner(onPressed: () => tapped = true)),
      ),
    );
    await tester.pump();

    expect(find.text('최신 후보 확인 중'), findsOneWidget);
    expect(find.text('결과 보기'), findsOneWidget);

    await tester.tap(find.text('결과 보기'));
    expect(tapped, isTrue);
  });

  test('option builder matches web query contract', () {
    final message = buildOptionFlowMessage(
      area: '서울',
      sigungu: '강남구',
      conditions: ['wheelchair', 'restroom'],
      preferences: [],
      exclusions: [],
      intensity: 'required',
      expansion: 'conditional',
    );

    expect(message, '서울 강남구에서 휠체어 접근과 장애인 화장실 모두 있는 관광지 추천해줘. 부족하면 서울 전체로 넓혀줘');
  });

  test('API base can target deployed FastAPI server', () {
    expect(
      AppConfig.normalizeApiBase('https://tourism-api.example.com/'),
      'https://tourism-api.example.com',
    );
  });
}
