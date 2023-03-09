import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_hallway/db_script/history_db.dart';
import 'package:smart_hallway/main_page/main_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart'
    as setting;
import 'package:sqflite/sqflite.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setting.Settings.init(cacheProvider: setting.SharePreferenceCache());
  Database db = await openDatabase(
      'history_db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute(HISTORY_DB_CREATION);
      }
  );
  prefs = await SharedPreferences.getInstance();
  runApp(MaterialApp(home: MainPage(db: db, prefs: prefs)));
}
