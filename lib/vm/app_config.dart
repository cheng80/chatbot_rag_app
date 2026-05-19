/// 실행 환경별 앱 설정을 한 곳에서 관리한다.
///
/// 개발·테스트는 기본 로컬 FastAPI를 사용하고, 배포 빌드는
/// `--dart-define=API_BASE=https://...` 로 외부 FastAPI 서버 주소를 주입한다.
class AppConfig {
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue: localApiBase,
  );

  static const debugUi = bool.fromEnvironment('DEBUG_UI', defaultValue: true);

  static const localApiBase = 'http://127.0.0.1:8000';

  static String normalizeApiBase(String value) {
    final trimmed = value.trim().replaceAll(RegExp(r'/+$'), '');
    return trimmed.isEmpty ? apiBase : trimmed;
  }
}
