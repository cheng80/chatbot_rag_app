import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../vm/tourism_card_presenter.dart';
import '../../vm/tourism_map_handler.dart';
import '../../vm/tourism_models.dart';
import 'common_widgets.dart';

class CardsPanel extends StatelessWidget {
  const CardsPanel({
    super.key,
    required this.cards,
    required this.cardCount,
    required this.queryText,
    required this.moreMessage,
    required this.onMore,
  });

  final List<TourismCard> cards;
  final int cardCount;
  final String queryText;
  final String? moreMessage;
  final ValueChanged<String> onMore;

  @override
  Widget build(BuildContext context) {
    return TourismPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('추천 카드', style: tourismTitleStyle)),
              AnimatedSwitcher(
                duration: tourismMotionDuration,
                child: Text(
                  '$cardCount개',
                  key: ValueKey(cardCount),
                  style: tourismCaptionStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: tourismSpace3),
          AnimatedSwitcher(
            duration: tourismMotionDuration,
            switchInCurve: tourismMotionCurve,
            switchOutCurve: Curves.easeInCubic,
            child: cards.isEmpty
                ? const Text(
                    '추천 카드가 아직 없습니다.',
                    key: ValueKey('empty-cards'),
                    style: tourismSecondaryStyle,
                  )
                : LayoutBuilder(
                    key: ValueKey('cards-list'),
                    builder: (context, constraints) {
                      final useTwoColumns = constraints.maxWidth >= 640;
                      final itemWidth = useTwoColumns
                          ? (constraints.maxWidth - tourismSpace3) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: tourismSpace3,
                        runSpacing: tourismSpace3,
                        children: cards
                            .map(
                              (card) => SizedBox(
                                width: itemWidth,
                                child: TourismAnimatedEntrance(
                                  child: PlaceCard(
                                    card: card,
                                    queryText: queryText,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
          ),
          AnimatedSwitcher(
            duration: tourismMotionDuration,
            child: moreMessage == null
                ? const SizedBox.shrink(key: ValueKey('no-more-cards'))
                : Padding(
                    key: ValueKey(moreMessage),
                    padding: const EdgeInsets.only(top: tourismSpace3),
                    child: OutlinedButton.icon(
                      onPressed: () => onMore(moreMessage!),
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: Text(moreMessage!),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class PlaceCard extends StatefulWidget {
  const PlaceCard({super.key, required this.card, required this.queryText});

  final TourismCard card;
  final String queryText;

  @override
  State<PlaceCard> createState() => PlaceCardState();
}

class PlaceCardState extends State<PlaceCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final evidence = cardEvidenceHighlights(widget.card, widget.queryText);
    final details = rawDetailEntries(widget.card);
    final layout = TourismLayoutMetrics.fromWidth(
      MediaQuery.sizeOf(context).width,
    );
    return AnimatedSize(
      duration: tourismMotionDuration,
      curve: tourismMotionCurve,
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: tourismMotionDuration,
        curve: tourismMotionCurve,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(tourismRadiusLg),
          border: Border.all(color: tourismLineColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: layout.cardMediaHeight,
              width: double.infinity,
              child: widget.card.imageUrl.isNotEmpty
                  ? CardImagePreview(
                      imageUrl: widget.card.imageUrl,
                      title: widget.card.title,
                    )
                  : const CardMediaFallback(),
            ),
            Padding(
              padding: const EdgeInsets.all(tourismSpace3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: tourismSpace2,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: tourismSpace2,
                    children: [
                      Expanded(
                        child: Text(
                          widget.card.title.isEmpty
                              ? '이름 없는 장소'
                              : widget.card.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      TourismPill(
                        text: widget.card.sourceName.isEmpty
                            ? '출처 확인'
                            : '출처 있음',
                      ),
                    ],
                  ),
                  Text(
                    widget.card.address.isEmpty
                        ? '주소 확인 필요'
                        : widget.card.address,
                    style: tourismSecondaryStyle,
                  ),
                  Text(
                    widget.card.reason.isEmpty
                        ? '추천 사유 확인 필요'
                        : widget.card.reason,
                    style: tourismBodyStyle,
                  ),
                  ...evidence.map(
                    (item) => EvidenceRow(label: item.$1, value: item.$2),
                  ),
                  const Divider(height: 20),
                  if (widget.card.tel.isNotEmpty)
                    DetailLine(label: '전화', value: widget.card.tel),
                  DetailLine(
                    label: '출처',
                    value: publicSourceName(widget.card.sourceName),
                  ),
                  Wrap(
                    spacing: tourismSpace2,
                    runSpacing: tourismSpace2,
                    children: [
                      if (details.isNotEmpty)
                        ActionChip(
                          label: Text(_showDetails ? '상세 접기' : '상세 정보'),
                          onPressed: () =>
                              setState(() => _showDetails = !_showDetails),
                        ),
                      if (TourismMapHandler.hasMapCoords(widget.card))
                        OutlinedButton.icon(
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('지도 보기'),
                          onPressed: () => _openMapsSheet(context),
                        ),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: tourismMotionDuration,
                    child: _showDetails
                        ? Column(
                            key: const ValueKey('details-open'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: tourismSpace2),
                              ...details.map(
                                (item) =>
                                    DetailLine(label: item.$1, value: item.$2),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('details-closed'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMapsSheet(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final maps = await TourismMapHandler.installedMaps();
      if (!context.mounted) return;
      if (maps.isEmpty) {
        _showMapMessage(context, '사용 가능한 지도 앱을 찾지 못했습니다.');
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return TourismAnimatedEntrance(
            child: SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const ListTile(
                    leading: Icon(Icons.map_outlined),
                    title: Text('지도 앱 선택', style: tourismTitleStyle),
                  ),
                  for (final map in maps)
                    ListTile(
                      leading: SvgPicture.asset(
                        map.icon,
                        width: 28,
                        height: 28,
                      ),
                      title: Text(map.mapName),
                      subtitle: Text(widget.card.title),
                      onTap: () async {
                        navigator.pop();
                        try {
                          await TourismMapHandler.showMarker(
                            map: map,
                            card: widget.card,
                          );
                        } on Object {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('지도 앱을 열지 못했습니다.')),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          );
        },
      );
    } on Object {
      if (!context.mounted) return;
      _showMapMessage(context, '지도 앱 목록을 확인하지 못했습니다.');
    }
  }

  void _showMapMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class CardImagePreview extends StatelessWidget {
  const CardImagePreview({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    final accessibleTitle = title.isEmpty ? '장소' : title;
    return Semantics(
      container: true,
      button: true,
      label: '$accessibleTitle 원본 사진 보기',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showCardImageDialog(
            context: context,
            imageUrl: imageUrl,
            title: accessibleTitle,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const CardMediaFallback(),
              ),
              const Positioned(
                right: tourismSpace2,
                bottom: tourismSpace2,
                child: CardImageZoomBadge(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardImageZoomBadge extends StatelessWidget {
  const CardImageZoomBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tourismSpace2,
          vertical: tourismSpace1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: tourismSpace1,
          children: [
            Icon(Icons.zoom_out_map, color: Colors.white, size: 15),
            Text(
              '원본',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCardImageDialog({
  required BuildContext context,
  required String imageUrl,
  required String title,
}) {
  final layout = TourismLayoutMetrics.fromWidth(
    MediaQuery.sizeOf(context).width,
  );
  final maxWidth = layout.deviceClass == TourismDeviceClass.phone
      ? double.infinity
      : layout.contentMaxWidth + 120;

  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.84),
    barrierDismissible: true,
    builder: (context) {
      return SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(tourismSpace4),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                    maxHeight:
                        MediaQuery.sizeOf(context).height - tourismSpace6 * 2,
                  ),
                  child: GestureDetector(
                    onTap: () {},
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const AspectRatio(
                              aspectRatio: 4 / 3,
                              child: CardMediaFallback(),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: tourismSpace3,
              right: tourismSpace3,
              child: IconButton.filled(
                tooltip: '사진 닫기',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      );
    },
  );
}
