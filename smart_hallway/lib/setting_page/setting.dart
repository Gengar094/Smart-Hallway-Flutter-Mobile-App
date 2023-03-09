import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingPage extends StatefulWidget {
  final SharedPreferences prefs;
  const SettingPage({super.key, required this.prefs});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _serverAddress = '';
  String _port = '';
  bool isConnected = false;

  String? config;

  @override
  void initState() {
    super.initState();
    _serverAddress = widget.prefs.getString('ipAddress') ?? '';
    _port = widget.prefs.getString('port') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // var config = XmlDocument.parse(loadAsset().then((res) => return res;));
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, isConnected),
          ),
          centerTitle: true,
          title: const Text('Smart Hallway'),
          backgroundColor: Colors.green,
        ),
        body: ListView(
              children: [
                SettingsGroup(
                  title: 'Connection',
                  children: <Widget>[
                    SwitchListTile(
                      title: const Text('Connection'),
                      value: isConnected,
                      onChanged: (res) => {connect(res)},
                    ),
                    TextInputSettingsTile(
                      title: 'Server IP address',
                      settingKey: 'key-server-ip-address',
                      initialValue:
                        widget.prefs.get('ipAddress')?.toString() ?? '',
                      onChange: (value) {
                        setState(() {
                           widget.prefs.setString('ipAddress', value);
                           _serverAddress = value;
                        });
                      },
                    ),
                    TextInputSettingsTile(
                      title: 'Server port',
                      settingKey: 'key-port',
                      initialValue:
                        widget.prefs.get('port')?.toString() ?? '',
                      onChange: (value) {
                        setState(() {
                          widget.prefs.setString('port', value);
                          _port = value;
                        });
                      },
                    ),
                  ],
                ),
                SettingsGroup(title: 'Recording Setting', children: <Widget>[
                  SwitchSettingsTile(
                    title: 'Verbose',
                    settingKey: 'key-verbose',
                    defaultValue:
                      widget.prefs.getBool('verbose') ?? false,
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setBool('verbose', value);
                      });
                    },
                  ),
                  SwitchSettingsTile(
                    title: 'Timestamp',
                    settingKey: 'key-timestamp',
                    defaultValue:
                      widget.prefs.getBool('timestamp') ?? false,
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setBool('timestamp', value);
                      });
                    },
                  ),
                  SwitchSettingsTile(
                    title: 'Images',
                    settingKey: 'key-images',
                      defaultValue:
                        widget.prefs.getBool('images') ?? false,
                      onChange: (value) {
                        setState(() {
                          widget.prefs.setBool('images', value);
                        });
                      }
                  ),
                  SwitchSettingsTile(
                    title: 'Video',
                    settingKey: 'key-video',
                    defaultValue:
                      widget.prefs.getBool('video') ?? true,
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setBool('video', value);
                      });
                    },
                  ),
                ]),
                SettingsGroup(title: 'Camera Setting', children: <Widget>[
                  TextInputSettingsTile(
                    title: 'Width',
                    settingKey: 'key-width',
                    initialValue:
                      widget.prefs.get('width')?.toString() ?? '1440',
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setString('width', value);
                      });
                    },
                  ),
                  TextInputSettingsTile(
                    title: 'Height',
                    settingKey: 'key-height',
                    initialValue:
                      widget.prefs.get('height')?.toString() ?? '1080',
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setString('height', value);
                      });
                    },
                  ),
                  SwitchSettingsTile(
                    title: 'Flip',
                    settingKey: 'key-flip',
                    defaultValue:
                      widget.prefs.getBool('flip') ?? false,
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setBool('flip', value);
                      });
                    },
                  ),
                  TextInputSettingsTile(
                    title: 'FPS',
                    settingKey: 'key-fps',
                    initialValue:
                      widget.prefs.get('fps')?.toString() ?? '60',
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setString('fps', value);
                      });
                    },
                  ),
                  TextInputSettingsTile(
                    title: 'Exposure time',
                    settingKey: 'key-exposure-time',
                    initialValue:
                      widget.prefs.get('exposureTime')?.toString() ?? '3000',
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setString('exposureTime', value);
                      });
                    },
                  ),
                  TextInputSettingsTile(
                    title: 'Warmup time',
                    settingKey: 'key-warm-up-time',
                    initialValue:
                      widget.prefs.get('warmUpTime')?.toString() ?? '3000',
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setString('warmUpTime', value);
                      });
                    },
                  ),
                  TextInputSettingsTile(
                    title: 'Image buffer',
                    settingKey: 'key-image-buffer',
                    initialValue:
                      widget.prefs.get('imageBuffer')?.toString() ?? '10',
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setString('imageBuffer', value);
                      });
                    },
                  ),
                  TextInputSettingsTile(
                    title: 'Image max',
                    settingKey: 'key-image-max',
                    initialValue:
                      widget.prefs.get('imageMax')?.toString() ?? '18000',
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setString('imageMax', value);
                      });
                    },
                  ),
                ]),
                SettingsGroup(title: 'Other', children: <Widget>[
                  TextInputSettingsTile(
                    title: 'Pixel format',
                    settingKey: 'key-pixel-format',
                    initialValue:
                      widget.prefs.get('pixelFormat')?.toString() ?? 'BayerRGB',
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setString('pixelFormat', value);
                      });
                    },
                  ),
                  TextInputSettingsTile(
                    title: 'Primary serial',
                    settingKey: 'key-primary-serial',
                    initialValue:
                      widget.prefs.get('primarySerial')?.toString() ?? '20010189',
                    onChange: (value) {
                      setState(() {
                         widget.prefs.setString('primarySerial', value);
                      });
                    },
                  ),
                  TextInputSettingsTile(
                    title: 'Output Path',
                    settingKey: 'key-output-path',
                    initialValue:
                      widget.prefs.get('outputPath')?.toString() ?? '/media/rehablab-1/agxSSD1/spinnaker-captures/multicam_captures/',
                    onChange: (value) {
                      setState(() {
                        widget.prefs.setString('outputPath', value);
                      });
                    },
                  ),
                ]),
              ],
            ),
        );
  }

  connect(bool res) {
    if (res && _serverAddress == '') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: const Text(
                    'Please Provide the IP address and port number of the server'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK')),
                ],
              ));
    } else if (res && _port == '') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Error'),
                content:
                    const Text('Please Provide the port number of the server'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK')),
                ],
              ));
    } else if (!res) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Warning'),
                content: const Text('Do you want to disconnect the server?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          isConnected = false;
                        });
                        Navigator.of(context).pop();
                      },
                      child: const Text('Continue')),
                ],
              ));
    } else {
      setState(() {
        isConnected = true;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            var dialog = AlertDialog(
              title: Text('Connection'),
              content: Text('Connecting to the server ...'),
            );

            Future.delayed(Duration(seconds: 5), () {
              Navigator.of(context).pop();
            });

            return dialog;
          });
    }
  }


// shared preference to persist the config data
//   Future<void> initSharedPreferences() async {
//     prefs = await SharedPreferences.getInstance();
// //   }
//
//   void saveConnectionState(String key, bool connected) async{
//     await widget.prefs.setBool(key, connected);
//   }
//
//   Future<bool?> getConnectionState(String key) async{
//     return widget.prefs.getBool(key);
//   }
//
//   void saveIPAddress(String key, String ipAdr) async{
//     await widget.prefs.setString(key, ipAdr);
//   }
//
//   Future<String?> getIPAddress(String key) async{
//     return widget.prefs.getString(key);
//   }
//
//   void savePort(String key, String port) async{
//     await widget.prefs.setString(key, port);
//   }
//
//   Future<String?> getPort(String key) async{
//     return widget.prefs.getString(key);
//   }
//
//   void saveVerbose(String key, bool verbose) async{
//     await widget.prefs.setBool(key, verbose);
//   }
//
//   Future<bool?> getVerbose(String key) async{
//     return widget.prefs.getBool(key);
//   }
//
//   void saveTimestamp(String key, bool timestamp) async{
//     await widget.prefs.setBool(key, timestamp);
//   }
//
//   Future<bool?> getTimestamp(String key) async{
//     return widget.prefs.getBool(key);
//   }
//
//   void saveImages(String key, bool image) async{
//     await widget.prefs.setBool(key, image);
//   }
//
//   Future<bool?> getImages(String key) async{
//     return widget.prefs.getBool(key);
//   }
//
//   void saveVideo(String key, bool video) async{
//     await widget.prefs.setBool(key, video);
//   }
//
//   Future<bool?> getVideo(String key) async{
//     return widget.prefs.getBool(key);
//   }
//
//   Future<int?> getWidth(String key) async{
//     return widget.prefs.getInt(key);
//   }
//
//   void saveWidth(String key, int width) async{
//     await widget.prefs.setInt(key, width);
//   }
//
//   Future<int?> getHeight(String key) async{
//     return widget.prefs.getInt(key);
//   }
//
//   void saveHeight(String key, int height) async{
//     await widget.prefs.setInt(key, height);
//   }
//
//   void saveFlip(String key, bool flip) async{
//     await widget.prefs.setBool(key, flip);
//   }
//
//   Future<bool?> getFlip(String key) async{
//     return widget.prefs.getBool(key);
//   }
//
//   void saveFPS(String key, int fps) async{
//     await widget.prefs.setInt(key, fps);
//   }
//
//   Future<int?> getFPS(String key) async{
//     return widget.prefs.getInt(key);
//   }
//
//   void saveExposureTime(String key, int exposureTime) async{
//     await widget.prefs.setInt(key, exposureTime);
//   }
//
//   Future<int?> getExposureTime(String key) async{
//     return widget.prefs.getInt(key);
//   }
//
//   void saveWarmUpTime(String key, int warmUpTime) async{
//     await widget.prefs.setInt(key, warmUpTime);
//   }
//
//   Future<int?> getWarmUpTime(String key) async{
//     return widget.prefs.getInt(key);
//   }
//
//   void saveImageBuffer(String key, int imageBuffer) async{
//     await widget.prefs.setInt(key, imageBuffer);
//   }
//
//   Future<int?> getImageBuffer(String key) async{
//     return widget.prefs.getInt(key);
//   }
//
//   void saveImageMax(String key, int imageMax) async{
//     await widget.prefs.setInt(key, imageMax);
//   }
//
//   Future<int?> getImageMax(String key) async{
//     return widget.prefs.getInt(key);
//   }
//
//   void savePixelFormat(String key, String pixelFormat) async{
//     await widget.prefs.setString(key, pixelFormat);
//   }
//
//   Future<String?> getPixelFormat(String key) async{
//     return widget.prefs.getString(key);
//   }
//
//   void savePrimarySerial(String key, int primarySerial) async{
//     await widget.prefs.setInt(key, primarySerial);
//   }
//
//   Future<int?> getPrimarySerial(String key) async{
//     return widget.prefs.getInt(key);
//   }
//
//   void saveOutputPath(String key, String outputPath) async{
//     await widget.prefs.setString(key, outputPath);
//   }
//
//   Future<String?> getOutputPath(String key) async{
//     return widget.prefs.getString(key);
//   }
}
