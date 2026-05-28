import 'database_service.dart';
import 'native/isar_database.dart';

/// Opens the native (Isar) database. Only compiled when `dart:io` toolchains
/// are available; the web target uses [database_factory_web.dart] instead.
Future<Database> openDatabase() async {
  final isar = await IsarDatabase.openIsar();
  return IsarDatabase(isar);
}
