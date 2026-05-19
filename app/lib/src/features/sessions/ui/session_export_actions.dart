import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/database_service.dart';
import '../../../database/models/measurement_models.dart';
import '../services/session_exporter.dart';

Future<void> pickFormatAndExport(
  BuildContext context,
  WidgetRef ref,
  RecordingSession session,
) async {
  final format = await _pickFormat(context);
  if (format == null) return;
  if (!context.mounted) return;
  await _exportSession(context, ref, session, format);
}

Future<String?> _pickFormat(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Export format'),
      content: const Text('Choose a file format.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, 'csv'),
          child: const Text('CSV'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, 'xlsx'),
          child: const Text('Excel'),
        ),
      ],
    ),
  );
}

Future<void> _exportSession(
  BuildContext context,
  WidgetRef ref,
  RecordingSession session,
  String format,
) async {
  final messenger = ScaffoldMessenger.of(context);

  final FileSaveLocation? location;
  try {
    location = await getSaveLocation(
      suggestedName: suggestedFileName(session, format),
      acceptedTypeGroups: [
        XTypeGroup(label: format.toUpperCase(), extensions: [format]),
      ],
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Save dialog failed: $e')));
    return;
  }
  if (location == null) return;

  try {
    final db = await ref.read(databaseServiceProvider.future);
    final readings = await db.getReadingsForSession(session.id);
    final data = SessionExportData(session, readings);

    final Uint8List bytes = format == 'csv'
        ? buildSessionCsv(data)
        : await compute(buildSessionXlsx, data);

    await File(location.path).writeAsBytes(bytes, flush: true);

    messenger.showSnackBar(
      SnackBar(
        content: Text('Exported ${readings.length} readings to ${location.path}'),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
  }
}
