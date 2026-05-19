import 'package:flutter/material.dart';

import '../../vm/tourism_models.dart';
import '../../vm/tourism_option_builder.dart';
import 'common_widgets.dart';

class Composer extends StatelessWidget {
  const Composer({
    super.key,
    required this.controller,
    required this.inputMode,
    required this.isLoading,
    required this.area,
    required this.sigungu,
    required this.intensity,
    required this.expansion,
    required this.regions,
    required this.conditions,
    required this.preferences,
    required this.exclusions,
    required this.optionSummary,
    required this.onOpenOptions,
    required this.onRegionPrompt,
    required this.onQuickPrompt,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String inputMode;
  final bool isLoading;
  final String area;
  final String sigungu;
  final String intensity;
  final String expansion;
  final List<RegionOption> regions;
  final Set<String> conditions;
  final Set<String> preferences;
  final Set<String> exclusions;
  final String optionSummary;
  final VoidCallback onOpenOptions;
  final ValueChanged<String> onRegionPrompt;
  final ValueChanged<String> onQuickPrompt;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return AnimatedContainer(
      duration: tourismMotionDuration,
      curve: tourismMotionCurve,
      padding: EdgeInsets.fromLTRB(10, 6, 10, 8 + bottomInset),
      decoration: const BoxDecoration(color: Color(0xffdcece2)),
      child: AnimatedContainer(
        duration: tourismMotionDuration,
        curve: tourismMotionCurve,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: const Color(0xfff8fcf8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ComposerActions(
              optionSummary: optionSummary,
              onOpenOptions: onOpenOptions,
              onRegionPrompt: onRegionPrompt,
              onQuickPrompt: onQuickPrompt,
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 1,
                    decoration: const InputDecoration(
                      labelText: '질문',
                      hintText: '예: 서울 강남구 근처에서 휠체어 관광지 추천해줘',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => onSubmit(),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  onPressed: isLoading ? null : onSubmit,
                  icon: AnimatedSwitcher(
                    duration: tourismMotionDuration,
                    child: Icon(
                      isLoading ? Icons.hourglass_top : Icons.send,
                      key: ValueKey(isLoading),
                    ),
                  ),
                  tooltip: inputMode == 'option' ? '조건으로 찾기' : '전송',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerActions extends StatelessWidget {
  const _ComposerActions({
    required this.optionSummary,
    required this.onOpenOptions,
    required this.onRegionPrompt,
    required this.onQuickPrompt,
  });

  final String optionSummary;
  final VoidCallback onOpenOptions;
  final ValueChanged<String> onRegionPrompt;
  final ValueChanged<String> onQuickPrompt;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ActionChip(
            avatar: const Icon(Icons.tune, size: 18),
            label: AnimatedSwitcher(
              duration: tourismMotionDuration,
              child: Text(
                optionSummary,
                key: ValueKey(optionSummary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onPressed: onOpenOptions,
          ),
          const SizedBox(width: 6),
          ...['서울 강남구', '부산 중구', '제주'].map(
            (region) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                label: Text(region),
                onPressed: () => onRegionPrompt(region),
              ),
            ),
          ),
          ...quickPrompts
              .take(2)
              .map(
                (prompt) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(prompt.$1),
                    onPressed: () => onQuickPrompt(prompt.$2),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class OptionSheet extends StatefulWidget {
  const OptionSheet({
    super.key,
    required this.area,
    required this.sigungu,
    required this.intensity,
    required this.expansion,
    required this.regions,
    required this.conditions,
    required this.preferences,
    required this.exclusions,
    required this.onAreaChanged,
    required this.onSigunguChanged,
    required this.onIntensityChanged,
    required this.onExpansionChanged,
    required this.onToggleCondition,
    required this.onTogglePreference,
    required this.onToggleExclusion,
  });

  final String area;
  final String sigungu;
  final String intensity;
  final String expansion;
  final List<RegionOption> regions;
  final Set<String> conditions;
  final Set<String> preferences;
  final Set<String> exclusions;
  final ValueChanged<String> onAreaChanged;
  final ValueChanged<String> onSigunguChanged;
  final ValueChanged<String> onIntensityChanged;
  final ValueChanged<String> onExpansionChanged;
  final ValueChanged<String> onToggleCondition;
  final ValueChanged<String> onTogglePreference;
  final ValueChanged<String> onToggleExclusion;

  @override
  State<OptionSheet> createState() => _OptionSheetState();
}

class _OptionSheetState extends State<OptionSheet> {
  late String _area = widget.area;
  late String _sigungu = widget.sigungu;
  late String _intensity = widget.intensity;
  late String _expansion = widget.expansion;
  late final Set<String> _conditions = {...widget.conditions};
  late final Set<String> _preferences = {...widget.preferences};
  late final Set<String> _exclusions = {...widget.exclusions};

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final sigunguList = widget.regions
        .firstWhere(
          (item) => item.name == _area,
          orElse: () => const RegionOption(name: '', sigungu: []),
        )
        .sigungu;

    return TourismAnimatedEntrance(
      child: SafeArea(
        child: AnimatedPadding(
          duration: tourismMotionDuration,
          curve: tourismMotionCurve,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.72,
            ),
            child: AnimatedSize(
              duration: tourismMotionDuration,
              curve: tourismMotionCurve,
              alignment: Alignment.topCenter,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '조건 선택',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('완료'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TourismDropdown(
                          label: '광역 지역',
                          value: _area,
                          items: [
                            '',
                            ...widget.regions.map((item) => item.name),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _area = value;
                              _sigungu = '';
                            });
                            widget.onAreaChanged(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TourismDropdown(
                          label: '시군구',
                          value: _sigungu,
                          items: ['', ...sigunguList],
                          onChanged: _area.isEmpty
                              ? null
                              : (value) {
                                  setState(() => _sigungu = value);
                                  widget.onSigunguChanged(value);
                                },
                        ),
                      ),
                    ],
                  ),
                  OptionChips(
                    title: '동행 상황',
                    values: conditionLabels,
                    selected: _conditions,
                    onToggle: (value) =>
                        _toggle(_conditions, value, widget.onToggleCondition),
                  ),
                  OptionChips(
                    title: '접근성 조건',
                    values: accessLabels,
                    selected: _conditions,
                    onToggle: (value) =>
                        _toggle(_conditions, value, widget.onToggleCondition),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TourismDropdown(
                          label: '조건 강도',
                          value: _intensity,
                          items: const ['required', 'optional'],
                          labels: const {
                            'required': '꼭 필요',
                            'optional': '있으면 좋음',
                          },
                          onChanged: (value) {
                            setState(() => _intensity = value);
                            widget.onIntensityChanged(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TourismDropdown(
                          label: '지역 확장',
                          value: _expansion,
                          items: const [
                            'local_only',
                            'conditional',
                            'area_now',
                          ],
                          labels: const {
                            'local_only': '요청 지역만',
                            'conditional': '부족하면 확장',
                            'area_now': '지금 확장',
                          },
                          onChanged: (value) {
                            setState(() => _expansion = value);
                            widget.onExpansionChanged(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  OptionChips(
                    title: '선호',
                    values: preferenceLabels,
                    selected: _preferences,
                    onToggle: (value) =>
                        _toggle(_preferences, value, widget.onTogglePreference),
                  ),
                  OptionChips(
                    title: '제외',
                    values: exclusionLabels,
                    selected: _exclusions,
                    onToggle: (value) =>
                        _toggle(_exclusions, value, widget.onToggleExclusion),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggle(
    Set<String> target,
    String value,
    ValueChanged<String> notifyParent,
  ) {
    setState(() {
      if (!target.add(value)) target.remove(value);
    });
    notifyParent(value);
  }
}

class PromptDrawer extends StatelessWidget {
  const PromptDrawer({
    super.key,
    required this.onRegionPrompt,
    required this.onQuickPrompt,
  });

  final ValueChanged<String> onRegionPrompt;
  final ValueChanged<String> onQuickPrompt;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('지역·예시 선택'),
      tilePadding: EdgeInsets.zero,
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children:
              const [
                    '서울',
                    '서울 강남구',
                    '서울 용산구',
                    '부산',
                    '부산 중구',
                    '인천 중구',
                    '제주',
                    '강릉',
                  ]
                  .map(
                    (region) => ActionChip(
                      label: Text(region),
                      onPressed: () => onRegionPrompt(region),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: quickPrompts
              .map(
                (prompt) => ActionChip(
                  label: Text(prompt.$1),
                  onPressed: () => onQuickPrompt(prompt.$2),
                ),
              )
              .toList(),
        ),
      ],
      onExpansionChanged: (_) {},
    );
  }
}

class TourismDropdown extends StatelessWidget {
  const TourismDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labels = const {},
  });

  final String label;
  final String value;
  final List<String> items;
  final Map<String, String> labels;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = items.contains(value) ? value : '';
    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(labels[item] ?? (item.isEmpty ? '선택' : item)),
            ),
          )
          .toList(),
      onChanged: onChanged == null ? null : (value) => onChanged!(value ?? ''),
    );
  }
}

class OptionChips extends StatelessWidget {
  const OptionChips({
    super.key,
    required this.title,
    required this.values,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final Map<String, String> values;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xff5a6d62),
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: values.entries
                .map(
                  (entry) => FilterChip(
                    label: Text(entry.value),
                    selected: selected.contains(entry.key),
                    onSelected: (_) => onToggle(entry.key),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
