# 무장애 관광 챗봇 Flutter 앱

`chatbot_rag` FastAPI 백엔드의 `/tourism/chat` API를 모바일 앱에서 사용하는 Flutter 클라이언트입니다.

백엔드 repo: `chatbot_rag`

앱 GitHub repo: `cheng80/chatbot_rag_app`

## 현재 범위

- 지역/조건 자연어 질문 입력
- `/tourism/chat` 응답 카드 렌더링
- 지역 선택/조건 확인/결과 부족 후속 질문 표시
- 추천 카드 상세 정보와 지도 앱 연결
- 개발용 진단 패널과 release형 사용자 화면 분리
- `session_id` 유지로 더 보기, 조건 추가, 조건 교체 같은 후속 질문 처리

백엔드는 TourAPI, Chroma, Ollama, fallback Markdown, 문맥/의도 classifier를 담당합니다. Flutter 앱은 서버 응답 계약을 표시하고 사용자의 후속 질문 흐름을 이어 주는 클라이언트입니다.

## 실행 전 백엔드

백엔드 repo에서 보이는 터미널로 FastAPI 서버를 실행합니다.

```bash
cd ../chatbot_rag
.venv/bin/python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

TourAPI 호출을 쓰지 않는 확인은 백엔드 서버를 fallback-only로 실행합니다.

```bash
cd ../chatbot_rag
TOURISM_LIVE_LOOKUP_ENABLED=false .venv/bin/python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

## Flutter 실행

```bash
flutter pub get
flutter test
flutter run --dart-define=API_BASE=http://127.0.0.1:8000
```

배포/외부 서버를 사용할 때는 `API_BASE`만 바꿉니다.

```bash
flutter run --dart-define=API_BASE=https://example-api.example.com
```

개발 진단 UI를 끄려면:

```bash
flutter run \
  --dart-define=API_BASE=http://127.0.0.1:8000 \
  --dart-define=DEBUG_UI=false
```

## 확인 질문

- `서울 강남구에서 휠체어 관광지 추천해줘`
- `중구에서 휠체어 관광지 추천해줘`
- `해운대 좌동 근처 유아차 관광지 추천해줘`
- `최신 정보 더 찾기`
- `그중 시장 말고 조용한 곳`
- `오늘 환율 알려줘`

## 백엔드 계약 메모

앱이 읽는 핵심 필드:

- `answer`
- `cards`
- `sources`
- `lookup_mode`
- `degraded`
- `warnings`
- `suggested_messages`
- `live_update_pending`
- `live_update_id`
- `reasoning_assist_used`
- `reasoning_assist_notes`

`access.visitkorea.or.kr/detail/...`처럼 콘텐츠 ID만으로 만든 추정 상세 URL은 앱에서 외부 링크로 쓰지 않습니다. 카드에는 출처명과 지도 연결을 우선 보여줍니다.

## QA 기준

주 타겟은 iPhone, Android phone, iPad, Android tablet입니다. 웹 빌드는 보조 확인용입니다.

필수 확인:

- 입력창과 카드 리스트가 작은 화면에서 서로 가리지 않음
- 지역 선택 후속 질문이 누락 없이 표시됨
- `더 보기`와 `최신 정보 더 찾기` 후속 질문이 같은 세션에서 동작
- 카드 상세 정보가 접힘/펼침으로 표시됨
- 지도 앱 연결이 가능한 카드에서 지도 선택 sheet 표시
- `DEBUG_UI=false`에서는 API 주소와 내부 진단 패널이 보이지 않음

## 개발 규칙

- `main.dart`는 앱 부트스트랩만 담당합니다.
- 화면은 `lib/view`, 반복 UI는 `lib/view/widgets`, 상태와 서버 처리는 `lib/vm`에 둡니다.
- Riverpod code generation은 사용하지 않습니다.
- 코드 주석은 필요한 경우 한글로 짧게 씁니다.
