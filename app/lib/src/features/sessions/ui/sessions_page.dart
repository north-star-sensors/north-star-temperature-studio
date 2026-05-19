import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/models/measurement_models.dart';
import '../state/sessions_list_provider.dart';
import 'session_export_actions.dart';

class SessionsPage extends ConsumerWidget {
  const SessionsPage({super.key});

  static const String routeName = '/sessions';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(sessionsListProvider),
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) =>
            Center(child: Text('Failed to load sessions: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Text('No recordings yet. Hit Record on the home page.'),
            );
          }
          return ListView.separated(
            itemCount: sessions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) => _SessionTile(session: sessions[i]),
          );
        },
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  const _SessionTile({required this.session});

  final RecordingSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(sessionReadingCountProvider(session.id));
    final note = session.note;

    return ListTile(
      leading: const Icon(Icons.show_chart),
      title: Text(_formatTimestamp(session.startTime)),
      subtitle: Text(
        [
          countAsync.when(
            data: (n) => '$n readings',
            loading: () => 'counting…',
            error: (e, st) => '? readings',
          ),
          if (note != null && note.isNotEmpty) note,
        ].join(' · '),
      ),
      trailing: IconButton(
        tooltip: 'Export',
        icon: const Icon(Icons.file_download),
        onPressed: () => pickFormatAndExport(context, ref, session),
      ),
    );
  }
}

String _formatTimestamp(DateTime t) {
  String pad(int n) => n.toString().padLeft(2, '0');
  return '${t.year}-${pad(t.month)}-${pad(t.day)} '
      '${pad(t.hour)}:${pad(t.minute)}:${pad(t.second)}';
}
