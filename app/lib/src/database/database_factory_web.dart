import 'database_service.dart';
import 'web/memory_database.dart';

/// Opens the web database — an in-memory store, since Isar 3 cannot compile to
/// web. Recordings persist for the page session only.
Future<Database> openDatabase() async => MemoryDatabase();
