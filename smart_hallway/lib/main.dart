import 'package:flutter/material.dart';
import 'package:smart_hallway/main_page/main_page.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart'
    as setting;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setting.Settings.init(cacheProvider: setting.SharePreferenceCache());
  runApp(MaterialApp(home: MainPage()));
}
