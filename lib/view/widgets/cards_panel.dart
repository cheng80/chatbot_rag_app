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
    required this.isWide,
    required this.moreMessage,
    required this.onMore,
  });

  final List<TourismCard> cards;
  final int cardCount;
  final String queryText;
  final bool isWide;
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
              const Expanded(
                child: Text(
                  '추천 카드',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
              AnimatedSwitcher(
                duration: tourismMotionDuration,
                child: Text(
                  '$cardCount개',
                  key: ValueKey(cardCount),
                  style: const TextStyle(
                    color: Color(0xff5a6d62),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: tourismMotionDuration,
            switchInCurve: tourismMotionCurve,
            switchOutCurve: Curves.easeInCubic,
            child: cards.isEmpty
                ? const Text(
                    '추천 카드가 아직 없습니다.',
                    key: ValueKey('empty-cards'),
                    style: TextStyle(color: Color(0xff5a6d62)),
                  )
                : LayoutBuilder(
                    key: ValueKey('cards-list'),
                    builder: (context, constraints) {
                      final itemWidth = isWide
                          ? (constraints.maxWidth - 10) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
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
                    padding: const EdgeInsets.only(top: 10),
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
    return AnimatedSize(
      duration: tourismMotionDuration,
      curve: tourismMotionCurve,
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: tourismMotionDuration,
        curve: tourismMotionCurve,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 7,
              child: widget.card.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.card.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const CardMediaFallback(),
                    )
                  : const CardMediaFallback(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.card.title.isEmpty
                              ? '이름 없는 장소'
                              : widget.card.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
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
                  const SizedBox(height: 8),
                  Text(
                    widget.card.address.isEmpty
                        ? '주소 확인 필요'
                        : widget.card.address,
                    style: const TextStyle(
                      color: Color(0xff5a6d62),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.card.reason.isEmpty
                        ? '추천 사유 확인 필요'
                        : widget.card.reason,
                    style: const TextStyle(height: 1.45),
                  ),
                  const SizedBox(height: 10),
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
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      if (details.isNotEmpty)
                        ActionChip(
                          label: Text(_showDetails ? '상세 접기' : '상세 정보'),
                          onPressed: () =>
                              setState(() => _showDetails = !_showDetails),
                        ),
                      if (TourismMapHandler.hasMapCoords(widget.card))
                        OutlinedButton.icon(
                          icon: SvgPicture.asset(
                            'packages/map_launcher/assets/icons/apple.svg',
                            width: 18,
                            height: 18,
                          ),
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
                            children: [
                              const SizedBox(height: 8),
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
                    title: Text(
                      '지도 앱 선택',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
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
