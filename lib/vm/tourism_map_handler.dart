import 'package:map_launcher/map_launcher.dart';

import 'tourism_models.dart';

/// 추천 카드에서 지도 검색 앱을 여는 외부 실행 담당 Handler다.
class TourismMapHandler {
  const TourismMapHandler._();

  static bool hasMapCoords(TourismCard card) =>
      card.mapX != null && card.mapY != null;

  static Future<List<AvailableMap>> installedMaps() {
    return MapLauncher.installedMaps;
  }

  static Future<void> showMarker({
    required AvailableMap map,
    required TourismCard card,
  }) async {
    final coords = _coordsFromCard(card);
    if (coords == null) throw const TourismMapException('지도 좌표가 없습니다.');

    await map.showMarker(
      coords: coords,
      title: card.title.isEmpty ? '관광지' : card.title,
      description: card.address,
    );
  }

  static Coords? _coordsFromCard(TourismCard card) {
    final longitude = card.mapX;
    final latitude = card.mapY;
    if (longitude == null || latitude == null) return null;
    return Coords(latitude, longitude);
  }
}

class TourismMapException implements Exception {
  const TourismMapException(this.message);

  final String message;
}
