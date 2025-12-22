// import 'dart:io';
// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
// import 'package:sqlite3/sqlite3.dart';
// import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// part 'app_database.g.dart';

// /// User table
// class Users extends Table {
//   TextColumn get id => text()();
//   TextColumn get name => text()();
//   TextColumn get email => text()();
//   TextColumn get token => text()();
//   TextColumn get restaurantsId => text().nullable()();
//   DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
//   DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

//   @override
//   Set<Column> get primaryKey => {id};
// }

// /// Menu cache table
// class MenuCache extends Table {
//   TextColumn get id => text()();
//   TextColumn get data => text()(); // JSON string
//   DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

//   @override
//   Set<Column> get primaryKey => {id};
// }

// /// App Database
// @DriftDatabase(tables: [Users, MenuCache])
// class AppDatabase extends _$AppDatabase {
//   AppDatabase() : super(_openConnection());

//   @override
//   int get schemaVersion => 1;

//   @override
//   MigrationStrategy get migration => MigrationStrategy(
//     onCreate: (Migrator m) async {
//       await m.createAll();
//     },
//     onUpgrade: (Migrator m, int from, int to) async {
//       // Handle migrations here
//     },
//   );
// }

// LazyDatabase _openConnection() {
//   return LazyDatabase(() async {
//     final dbFolder = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dbFolder.path, 'food_order_app.db'));

//     // Make sqlite3 pick a more suitable location for temporary files
//     if (Platform.isAndroid) {
//       await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
//     }

//     // Make sqlite3 use the correct temp directory on Android
//     final cachebase = (await getTemporaryDirectory()).path;
//     sqlite3.tempDirectory = cachebase;

//     return NativeDatabase.createInBackground(file);
//   });
// }
