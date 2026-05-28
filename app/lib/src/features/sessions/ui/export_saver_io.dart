import 'dart:io';

import 'package:file_selector/file_selector.dart';

/// Native save: prompt for a location and write the bytes to disk.
/// Returns the saved path, or null if the user cancelled.
Future<String?> saveExportBytes({
  required String suggestedName,
  required String extension,
  required List<int> bytes,
}) async {
  final location = await getSaveLocation(
    suggestedName: suggestedName,
    acceptedTypeGroups: [
      XTypeGroup(label: extension.toUpperCase(), extensions: [extension]),
    ],
  );
  if (location == null) return null;
  await File(location.path).writeAsBytes(bytes, flush: true);
  return location.path;
}
