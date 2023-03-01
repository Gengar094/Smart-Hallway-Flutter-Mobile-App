import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xml/xml.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String _serverAddress = '';
  String _port = '';
  bool isConnected = false;

  String? config;

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
        body: FutureBuilder(
          future: rootBundle.loadString('assets/config.xml'),
          builder: (context, snapshot) {
            var config = XmlDocument.parse(snapshot.data.toString());
            _serverAddress = config
                .findElements('main')
                .first
                .findElements('serverip')
                .single
                .text;
            _port = config
                .findElements('main')
                .first
                .findElements('serverport')
                .single
                .text;
            return ListView(
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
                      initialValue: config
                          .findElements('main')
                          .first
                          .findElements('serverip')
                          .single
                          .text,
                      onChange: (value) => {
                        _serverAddress = value,
                      },
                    ),
                    TextInputSettingsTile(
                      title: 'Server port',
                      settingKey: 'key-port',
                      initialValue: config
                          .findElements('main')
                          .first
                          .findElements('serverport')
                          .single
                          .text,
                      onChange: (value) => {
                        _port = value,
                      },
                    ),
                  ],
                ),
                SettingsGroup(title: 'Recording Setting', children: <Widget>[
                  SwitchSettingsTile(
                    title: 'Verbose',
                    settingKey: 'key-verbose',
                    defaultValue: config
                            .findElements('main')
                            .first
                            .findElements('verbose')
                            .single
                            .text ==
                        'true',
                  ),
                  SwitchSettingsTile(
                    title: 'Timestamp',
                    settingKey: 'key-timestamp',
                    defaultValue: config
                            .findElements('main')
                            .first
                            .findElements('timestamps')
                            .single
                            .text ==
                        'true',
                  ),
                  SwitchSettingsTile(
                    title: 'Images',
                    settingKey: 'key-images',
                    defaultValue: config
                            .findElements('main')
                            .first
                            .findElements('images')
                            .single
                            .text ==
                        'true',
                  ),
                  SwitchSettingsTile(
                    title: 'Video',
                    settingKey: 'key-video',
                    defaultValue: config
                            .findElements('main')
                            .first
                            .findElements('video')
                            .single
                            .text ==
                        'true',
                  ),
                ]),
                SettingsGroup(title: 'Camera Setting', children: <Widget>[
                  TextInputSettingsTile(
                    title: 'Width',
                    settingKey: 'key-width',
                    initialValue: config
                        .findElements('main')
                        .first
                        .findElements('width')
                        .single
                        .text,
                  ),
                  TextInputSettingsTile(
                    title: 'Height',
                    settingKey: 'key-height',
                    initialValue: config
                        .findElements('main')
                        .first
                        .findElements('height')
                        .single
                        .text,
                  ),
                  SwitchSettingsTile(
                    title: 'Flip',
                    settingKey: 'key-flip',
                    defaultValue: config
                            .findElements('main')
                            .first
                            .findElements('flip')
                            .single
                            .text ==
                        'true',
                  ),
                  TextInputSettingsTile(
                    title: 'FPS',
                    settingKey: 'key-fps',
                    initialValue: config
                        .findElements('main')
                        .first
                        .findElements('fps')
                        .single
                        .text,
                  ),
                  TextInputSettingsTile(
                    title: 'Exposure time',
                    settingKey: 'key-exposure-time',
                    initialValue: config
                        .findElements('main')
                        .first
                        .findElements('exposuretime')
                        .single
                        .text,
                  ),
                  TextInputSettingsTile(
                    title: 'Warmup time',
                    settingKey: 'key-warm-up-time',
                    initialValue: config
                        .findElements('main')
                        .first
                        .findElements('warmuptime')
                        .single
                        .text,
                  ),
                  TextInputSettingsTile(
                    title: 'Image buffer',
                    settingKey: 'key-image-buffer',
                    initialValue: config
                        .findElements('main')
                        .first
                        .findElements('imagebuffer')
                        .single
                        .text,
                  ),
                  TextInputSettingsTile(
                    title: 'Image max',
                    settingKey: 'key-image-max',
                    initialValue: config
                        .findElements('main')
                        .first
                        .findElements('imagemax')
                        .single
                        .text,
                  ),
                ]),
                SettingsGroup(title: 'Other', children: <Widget>[
                  TextInputSettingsTile(
                    title: 'Pixel format',
                    settingKey: 'key-pixel-format',
                    initialValue: config
                        .findElements('main')
                        .first
                        .findElements('pixelformat')
                        .single
                        .text,
                  ),
                  TextInputSettingsTile(
                    title: 'Primary serial',
                    settingKey: 'key-primary-serial',
                    initialValue: config
                        .findElements('main')
                        .first
                        .findElements('primaryserial')
                        .single
                        .text,
                  ),
                  TextInputSettingsTile(
                    title: 'Output Path',
                    settingKey: 'key-output-path',
                    initialValue: config
                        .findElements('main')
                        .first
                        .findElements('outpath')
                        .single
                        .text,
                  ),
                ]),
              ],
            );
          },
        ));
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
}
