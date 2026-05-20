import 'package:flutter/material.dart';

import 'view/tourism_chat_screen.dart';
import 'view/widgets/common_widgets.dart';

class TourismChatApp extends StatelessWidget {
  const TourismChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '무장애 관광 상담',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: tourismPrimaryColor,
          brightness: Brightness.light,
          surface: tourismSurfaceColor,
        ),
        scaffoldBackgroundColor: tourismPageColor,
        useMaterial3: true,
        fontFamilyFallback: const ['Apple SD Gothic Neo', 'Noto Sans KR'],
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: tourismInkColor,
          displayColor: tourismInkColor,
        ),
      ),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // iOS 접근성 글자 크기가 과하게 커져도 주요 입력부가 화면을 덮지 않도록 상한을 둔다.
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 1,
              maxScaleFactor: 1.18,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const TourismChatScreen(),
    );
  }
}
