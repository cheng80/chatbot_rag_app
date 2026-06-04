# Chatbot RAG App Portfolio Screenshots

## 캡처 환경

- 캡처일: 2026-05-31
- 실행 환경: Flutter web, Chrome
- Flutter: 3.41.7 stable
- 화면 크기: 900 x 1200 CSS px
- 앱 실행:
  - `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5011 --dart-define=API_BASE=http://127.0.0.1:8001 --dart-define=DEBUG_UI=false`
- 백엔드 실행:
  - FastAPI 로컬 서버
  - `TOURISM_LIVE_LOOKUP_ENABLED=false`
  - `http://127.0.0.1:8001`

## 캡처 파일

- `chatbot-rag-app-hero-chat.png`
  - 질문: `서울 강남구 휠체어 관광지 추천`
  - 사용자 질문, RAG 답변, 출처, 추천 카드가 한 화면에 보이도록 캡처했습니다.
- `chatbot-rag-app-home.png`
  - 앱 첫 진입 화면입니다.
  - 무장애 관광 상담 앱의 용도와 기본 안내 문구가 보이도록 캡처했습니다.
- `chatbot-rag-app-result-detail.png`
  - 추천 카드의 `상세 정보`를 펼친 뒤 캡처했습니다.
  - 접근성 근거, 출처, 지도 보기 액션이 보이도록 스크롤 위치를 조정했습니다.
- `chatbot-rag-app-state.png`
  - 브라우저 네트워크를 오프라인으로 전환한 뒤 요청해 서버 연결 실패 상태를 캡처했습니다.

## 검증 메모

- 디자인용 가짜 화면이 아니라 현재 Flutter 앱을 실행한 실제 화면입니다.
- `DEBUG_UI=false`로 실행하여 진단 패널과 내부 디버그 UI가 보이지 않게 했습니다.
- 개인 계정 정보와 비밀키는 화면에 표시되지 않았습니다.
