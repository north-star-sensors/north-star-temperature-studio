import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../database/database_service.dart';
import '../../../database/models/measurement_models.dart';

part 'sessions_list_provider.g.dart';

@riverpod
Future<List<RecordingSession>> sessionsList(SessionsListRef ref) async {
  final db = await ref.watch(databaseServiceProvider.future);
  return db.getAllSessionsNewestFirst();
}

@riverpod
Future<int> sessionReadingCount(
  SessionReadingCountRef ref,
  int sessionId,
) async {
  final db = await ref.watch(databaseServiceProvider.future);
  return db.countReadingsForSession(sessionId);
}
