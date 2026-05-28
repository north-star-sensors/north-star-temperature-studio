import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web save: trigger a browser download via a temporary object URL. The
/// browser routes the file to the user's Downloads folder, so the final path
/// isn't knowable — we return the suggested name for the confirmation message.
Future<String?> saveExportBytes({
  required String suggestedName,
  required String extension,
  required List<int> bytes,
}) async {
  final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  final blob = web.Blob(
    <JSAny>[data.toJS].toJS,
    web.BlobPropertyBag(type: 'application/octet-stream'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor =
      web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = suggestedName;
  anchor.click();
  web.URL.revokeObjectURL(url);
  return suggestedName;
}
