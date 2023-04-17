import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_hallway/util/ssh.dart';
import 'package:xml/xml.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../util/util.dart';

class SettingPage extends StatefulWidget {
  final SharedPreferences prefs;
  // final Function absortParentFilmingProcess;
  const SettingPage({super.key, required this.prefs});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with WidgetsBindingObserver{
  SSHConnection ssh = SSHConnection();
  String? config;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      widget.prefs.setBool('key-connected', false);
      print('connection closed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, widget.prefs.getBool('key-connected')),
          ),
            centerTitle: true,
            title: const Text('Smart Hallway'),
                 backgroundColor: Colors.green,
        ),
        body: ListView(
          children: [
            SwitchListTile(
              title: Text('Connection'),
              value: widget.prefs.getBool('key-connected') ?? false ,
              onChanged: (value) {
                  _toggleSSHConnection(value);
              }
            ),
            const Divider(
              thickness: .5,
              height: 0,
            ),
            TextInputSettingsTile(
              title: 'Server IP address',
              settingKey: 'key-server-ip-address',
              initialValue:
                widget.prefs.get('key-server-ip-address')?.toString() ?? '',
              onChange: (value) {
                setState(() {
                   widget.prefs.setString('key-server-ip-address', value);
                });
              },
            ),
            const Divider(
              thickness: .5,
              height: 0,
            ),
            TextInputSettingsTile(
              title: 'Server port',
              settingKey: 'key-port',
              initialValue:
                widget.prefs.get('key-port')?.toString() ?? '',
              onChange: (value) {
                setState(() {
                  widget.prefs.setString('key-port', value);
                });
              },
            ),
            const Divider(
              thickness: .5,
              height: 0,
            ),
            SettingsGroup(title: 'Recording Setting', children: <Widget>[
              SwitchSettingsTile(
                title: 'Verbose',
                settingKey: 'key-verbose',
                defaultValue:
                  widget.prefs.getBool('key-verbose') ?? false,
                onChange: (value) {
                  setState(() {
                    widget.prefs.setBool('key-verbose', value);
                  });
                },
              ),
              SwitchSettingsTile(
                title: 'Timestamp',
                settingKey: 'key-timestamp',
                defaultValue:
                  widget.prefs.getBool('key-timestamp') ?? false,
                onChange: (value) {
                  setState(() {
                    widget.prefs.setBool('key-timestamp', value);
                  });
                },
              ),
              SwitchSettingsTile(
                title: 'Images',
                settingKey: 'key-images',
                  defaultValue:
                    widget.prefs.getBool('key-images') ?? false,
                  onChange: (value) {
                    setState(() {
                      widget.prefs.setBool('key-images', value);
                    });
                  }
              ),
              SwitchSettingsTile(
                title: 'Video',
                settingKey: 'key-video',
                defaultValue:
                  widget.prefs.getBool('key-video') ?? true,
                onChange: (value) {
                  setState(() {
                    widget.prefs.setBool('key-video', value);
                  });
                },
              ),
            ]),
            SettingsGroup(title: 'Camera Setting', children: <Widget>[
              TextInputSettingsTile(
                title: 'Width',
                settingKey: 'key-width',
                initialValue:
                  widget.prefs.get('key-width')?.toString() ?? '1440',
                onChange: (value) {
                  setState(() {
                    widget.prefs.setString('key-width', value);
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              TextInputSettingsTile(
                title: 'Height',
                settingKey: 'key-height',
                initialValue:
                  widget.prefs.get('key-height')?.toString() ?? '1080',
                onChange: (value) {
                  setState(() {
                    widget.prefs.setString('key-height', value);
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              SwitchSettingsTile(
                title: 'Flip',
                settingKey: 'key-flip',
                defaultValue:
                  widget.prefs.getBool('key-flip') ?? false,
                onChange: (value) {
                  setState(() {
                    widget.prefs.setBool('key-flip', value);
                  });
                },
              ),

              TextInputSettingsTile(
                title: 'FPS',
                settingKey: 'key-fps',
                initialValue:
                  widget.prefs.get('key-fps')?.toString() ?? '60',
                onChange: (value) {
                  setState(() {
                    widget.prefs.setString('key-fps', value);
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              TextInputSettingsTile(
                title: 'Exposure time',
                settingKey: 'key-exposure-time',
                initialValue:
                  widget.prefs.get('key-exposure-time')?.toString() ?? '3000',
                onChange: (value) {
                  setState(() {
                    widget.prefs.setString('key-exposure-time', value);
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              TextInputSettingsTile(
                title: 'Warmup time',
                settingKey: 'key-warm-up-time',
                initialValue:
                  widget.prefs.get('key-warm-up-time')?.toString() ?? '3000',
                onChange: (value) {
                  setState(() {
                    widget.prefs.setString('key-warm-up-time', value);
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              TextInputSettingsTile(
                title: 'Image buffer',
                settingKey: 'key-image-buffer',
                initialValue:
                  widget.prefs.get('key-image-buffer')?.toString() ?? '10',
                onChange: (value) {
                  setState(() {
                    widget.prefs.setString('key-image-buffer', value);
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              TextInputSettingsTile(
                title: 'Image max',
                settingKey: 'key-image-max',
                initialValue:
                  widget.prefs.get('key-image-max')?.toString() ?? '18000',
                onChange: (value) {
                  setState(() {
                    widget.prefs.setString('key-image-max', value);
                  });
                },
              ),
            ]),
            const Divider(
              thickness: .5,
              height: 0,
            ),
            SettingsGroup(title: 'Other', children: <Widget>[
              TextInputSettingsTile(
                title: 'Pixel format',
                settingKey: 'key-pixel-format',
                initialValue:
                  widget.prefs.get('key-pixel-format')?.toString() ?? 'BayerRGB',
                onChange: (value) {
                  setState(() {
                    widget.prefs.setString('key-pixel-format', value);
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              TextInputSettingsTile(
                title: 'Primary serial',
                settingKey: 'key-primary-serial',
                initialValue:
                  widget.prefs.get('key-primary-serial')?.toString() ?? '20010189',
                onChange: (value) {
                  setState(() {
                     widget.prefs.setString('key-primary-serial', value);
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              TextInputSettingsTile(
                title: 'Output Path',
                settingKey: 'key-output-path',
                initialValue:
                  widget.prefs.get('key-output-path')?.toString() ?? '/media/rehablab-1/agxSSD1/spinnaker-captures/multicam_captures/',
                onChange: (value) {
                  setState(() {
                    widget.prefs.setString('key-output-path', value);
                  });
                },
              ),
            ]),
          ],
        ));
  }

  void _toggleSSHConnection(bool value) {
    bool connected = widget.prefs.getBool('key-connected') ?? false;
    if (widget.prefs.getString('key-server-ip-address') == '' || widget.prefs.getString('key-port') == '') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Please provide the IP address and port number of the server'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK')),
            ],
          ));
    } else if (!isValidIpAddress(widget.prefs.getString('key-server-ip-address') ?? '') && !connected) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Please provide a valid IP address'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK')),
            ],
          ));
    } else if (!isValidPortNumber(widget.prefs.getString('key-port') ?? '') && !connected) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Please provide a valid port number'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK')),
            ],
          ));
    } else {
      setState(() {
        var connected = widget.prefs.getBool('key-connected') ?? false;
        if (!connected) {
          // connect to SSH server
          try {
            ssh.connect(
                host: widget.prefs.getString('key-server-ip-address') ?? 'localhost',
                port: int.parse(widget.prefs.getString('key-port') ?? '22'),
                username: 'zharry',
                passwordOrKey: 'Zyh&*(980110',
            ).then((res) {
              if (res == 'session_connected') {
                setState(() {
                  widget.prefs.setBool('key-connected', true);
                });
              }
            });
          } on PlatformException catch (e) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: const Text(
                      'SSH Connection error'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK')),
                  ],
                ));
          }
        } else {
          // disconnect from SSH server
          widget.prefs.setBool('key-connected', false);
          ssh.isConnected().then(
                  (connected) {
                if (connected) {
                  ssh.disconnect();
                }
              });
        }
      });
    }
  }



}
