import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../vm/app_config.dart';
import '../../vm/tourism_backend_notifier.dart';
import 'common_widgets.dart';

class DebugPanel extends ConsumerWidget {
  const DebugPanel({
    super.key,
    required this.apiBaseController,
    required this.state,
    required this.diagnostics,
  });

  final TextEditingController apiBaseController;
  final String state;
  final List<String> diagnostics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backend = ref.watch(tourismBackendNotifierProvider);
    return Container(
      color: tourismSurfaceSoftColor,
      padding: const EdgeInsets.all(tourismSpace3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: tourismSpace2,
        children: [
          TextField(
            controller: apiBaseController,
            decoration: const InputDecoration(
              labelText: 'API',
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          ListenableBuilder(
            listenable: apiBaseController,
            builder: (context, _) {
              final base = apiBaseController.text.trim().replaceAll(
                RegExp(r'/+$'),
                '',
              );
              final apiBase = AppConfig.normalizeApiBase(base);
              return Wrap(
                spacing: tourismSpace2,
                runSpacing: tourismSpace2,
                children: [
                  ActionChip(
                    label: const Text('Swagger'),
                    onPressed: () => launchUrl(Uri.parse('$apiBase/docs')),
                  ),
                  ActionChip(
                    label: const Text('ReDoc'),
                    onPressed: () => launchUrl(Uri.parse('$apiBase/redoc')),
                  ),
                  ActionChip(
                    label: const Text('OpenAPI JSON'),
                    onPressed: () =>
                        launchUrl(Uri.parse('$apiBase/openapi.json')),
                  ),
                ],
              );
            },
          ),
          Wrap(
            spacing: tourismSpace2,
            runSpacing: tourismSpace2,
            children: [
              ActionChip(
                label: Text(
                  backend.isChecking ? '서버 확인 중' : backend.statusText,
                ),
                onPressed: backend.isChecking
                    ? null
                    : () => ref
                          .read(tourismBackendNotifierProvider.notifier)
                          .check(apiBaseController.text),
              ),
              TourismPill(
                text: state,
                tone: state.contains('오류') || state.contains('실패')
                    ? PillTone.error
                    : PillTone.normal,
              ),
              ...backend.capabilities.map((text) => TourismPill(text: text)),
              if (backend.errorMessage != null)
                TourismPill(text: backend.errorMessage!, tone: PillTone.error),
              ...diagnostics.map(
                (text) => TourismPill(text: text, tone: PillTone.warn),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
