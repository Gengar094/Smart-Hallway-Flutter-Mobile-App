
import 'package:smart_hallway/main.dart';
import 'package:xml/xml.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../util/client.dart';
import '../util/util.dart';

class SettingPage extends StatefulWidget {
  final SharedPreferences prefs;
  // final Function absortParentFilmingProcess;
  const SettingPage({super.key, required this.prefs});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with WidgetsBindingObserver{
  Client io = Client();
  String? config;
  bool verbose = prefs.getBool('key-verbose') ?? false;
  bool timestamps = prefs.getBool('key-timestamp') ?? false;
  bool images = prefs.getBool('key-images') ?? false;
  bool video = prefs.getBool('key-video') ?? false;
  String width =  prefs.get('key-width')?.toString() ?? '1440';
  String height = prefs.get('key-height')?.toString() ?? '1080';
  bool flip = prefs.getBool('key-flip') ?? false;
  String fps = prefs.getString('key-fps')?.toString() ?? '60';
  String exposureTime = prefs.getString('key-exposure-time')?.toString() ?? '3000';
  String warmupTime = prefs.getString('key-warm-up-time')?.toString() ?? '3000';
  String imageBuffer = prefs.getString('key-image-buffer')?.toString() ?? '10';
  String imageMax = prefs.getString('key-image-max')?.toString() ?? '18000';
  String pixelFormat = prefs.getString('key-pixel-format')?.toString() ?? 'BayerRGB';
  String primarySerial = prefs.getString('key-primary-serial')?.toString() ?? '20010189';
  String outputPath = prefs.getString('key-output-path')?.toString() ?? '/media/rehablab-1/agxSSD1/spinnaker-captures/multicam_captures/';


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
                  _toggleConnection(value);
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
              SwitchListTile(
                title: Text('Verbose'),
                value: verbose,
                onChanged: (value) {
                  setState(() {
                    if (widget.prefs.getBool('key-connected') ?? false) {
                      configXML("verbose", value.toString()).then((v) {
                        widget.prefs.setBool('key-verbose', value);
                        verbose = value;
                      });
                    } else {
                      showError();
                    }
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              SwitchListTile(
                title: Text('Timestamp'),
                value: timestamps,
                onChanged: (value) {
                  setState(() {
                    if (widget.prefs.getBool('key-connected') ?? false) {
                      configXML("timestamps", value.toString()).then((v) {
                        widget.prefs.setBool('key-timestamp', value);
                        timestamps = value;
                      });
                    } else {
                      showError();
                    }
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              SwitchListTile(
                title: Text('Images'),
                value: images,
                onChanged: (value) {
                  setState(() {
                    if (widget.prefs.getBool('key-connected') ?? false) {
                      configXML("images", value.toString()).then((v) {
                        widget.prefs.setBool('key-images', value);
                        images = value;
                      });
                    } else {
                      showError();
                    }
                  });
                }
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              SwitchListTile(
                title: Text('Video'),
                value: video,
                onChanged: (value) {
                  setState(() {
                    if (widget.prefs.getBool('key-connected') ?? false) {
                      configXML("video", value.toString()).then((v) {
                        widget.prefs.setBool('key-video', value);
                        video = value;
                      });
                    } else {
                      showError();
                    }
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
            ]),
            SettingsGroup(title: 'Camera Setting', children: <Widget>[
              TextInputSettingsTile(
                title: 'Width',
                settingKey: 'key-width',
                enabled: widget.prefs.getBool('key-connected') ?? false,
                initialValue:
                  width,
                onChange: (value) {
                  setState(() {
                    configXML("width", value.toString()).then((v) {
                      widget.prefs.setString('key-width', value);
                      width = value;
                    });
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
                enabled: widget.prefs.getBool('key-connected') ?? false,
                initialValue:
                  height,
                onChange: (value) {
                  setState(() {
                    configXML("height", value.toString()).then((v) {
                      widget.prefs.setString('key-height', value);
                      height = value;
                    });
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              SwitchListTile(
                title: Text('Flip'),
                value: flip,
                onChanged: (value) {
                  setState(() {
                    if (widget.prefs.getBool('key-connected') ?? false) {
                      configXML("flip", value.toString()).then((v) {
                        widget.prefs.setBool('key-flip', value);
                        flip = value;
                      });
                    } else {
                      showError();
                    }
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              TextInputSettingsTile(
                title: 'FPS',
                settingKey: 'key-fps',
                enabled: widget.prefs.getBool('key-connected') ?? false,
                initialValue:
                  fps,
                onChange: (value) {
                  setState(() {
                    configXML("fps", value.toString()).then((v) {
                      widget.prefs.setString('key-fps', value);
                      fps = value;
                    });
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
                enabled: widget.prefs.getBool('key-connected') ?? false,
                initialValue:
                  exposureTime,
                onChange: (value) {
                  setState(() {
                    configXML("exposuretime", value.toString()).then((v) {
                      widget.prefs.setString('key-exposure-time', value);
                      exposureTime = value;
                    });
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
                enabled: widget.prefs.getBool('key-connected') ?? false,
                initialValue:
                  warmupTime,
                onChange: (value) {
                  setState(() {
                    configXML("warmuptime", value.toString()).then((v) {
                      widget.prefs.setString('key-warm-up-time', value);
                      warmupTime = value;
                    });
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
                enabled: widget.prefs.getBool('key-connected') ?? false,
                initialValue:
                  imageBuffer,
                onChange: (value) {
                  setState(() {
                    configXML("imagebuffer", value.toString()).then((v) {
                      widget.prefs.setString('key-image-buffer', value);
                      imageBuffer = value;
                    });
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
                enabled: widget.prefs.getBool('key-connected') ?? false,
                initialValue:
                  imageMax,
                onChange: (value) {
                  setState(() {
                    configXML("imagemax", value.toString()).then((v) {
                      widget.prefs.setString('key-image-max', value);
                      imageMax = value;
                    });
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
                enabled: widget.prefs.getBool('key-connected') ?? false,
                initialValue:
                  pixelFormat,
                onChange: (value) {
                  setState(() {
                    configXML("pixelformat", value.toString()).then((v) {
                      widget.prefs.setString('key-pixel-format', value);
                      pixelFormat = value;
                    });
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
                enabled: widget.prefs.getBool('key-connected') ?? false,
                initialValue:
                 primarySerial,
                onChange: (value) {
                  setState(() {
                    configXML("primaryserial", value.toString()).then((v) {
                      widget.prefs.setString('key-primary-serial', value);
                      primarySerial = value;
                    });
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
                enabled: widget.prefs.getBool('key-connected') ?? false,
                initialValue:
                  outputPath,
                onChange: (value) {
                  setState(() {
                    configXML("outpath", value.toString()).then((v) {
                      widget.prefs.setString('key-output-path', value);
                      outputPath = value;
                    });
                  });
                },
              ),
            ]),
          ],
        ));
  }

  void showError () {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'Connection error'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK')),
          ],
        ));
  }

  Future<void> configXML(String tag, String value) {
    return io.setConfiguration(tag, value);
  }

  void _toggleConnection(bool value) {
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
          // connect to server
          try {
            io.connect(
              ip: widget.prefs.getString('key-server-ip-address') ??
                  'localhost',
              port: int.parse(widget.prefs.getString('key-port') ?? '3000'),
            ).then((value) {
              if (io.isConnected() ?? false) {
                setState(() {
                  widget.prefs.setBool('key-connected', true);
                    fetchLocalSetting().then((value) {
                  });
                });
              } else {
                showError();
              }
            });
          } on SocketException catch (e) {
            showError();
          }
            // print(io.isConnected());
        } else {
          // disconnect from server
          if (io.isConnected() ?? false) {
            io.disconnect().then((value) {
              setState(() {
                widget.prefs.setBool('key-connected', false);
              });
            });
          }
          setState(() {
            widget.prefs.setBool('key-connected', false);
          });
        }
      });
    }
  }

  Future<void> fetchLocalSetting() async {
    Future<String> future = io.fetchSetting();
    await future.then((xmlStr) {
      XmlDocument xmlDocument = XmlDocument.parse(xmlStr);
      XmlElement root = xmlDocument.rootElement;

      verbose = root.findElements('verbose').single.text == 'true';
      widget.prefs.setBool('key-verbose', verbose);
      timestamps = root.findElements('timestamps').single.text == 'true';
      widget.prefs.setBool('key-timestamp', timestamps);
      video = root.findElements('video').single.text == 'true';
      widget.prefs.setBool('key-video', video);
      images = root.findElements('images').single.text == 'true';
      widget.prefs.setBool('key-images', images);

      width = root.findElements('width').single.text;
      widget.prefs.setString('key-width', width);
      height = root.findElements('height').single.text;
      widget.prefs.setString('key-height', height);
      flip = root.findElements('flip').single.text == 'true';
      widget.prefs.setBool('key-flip', flip);
      fps = root.findElements('fps').single.text;
      widget.prefs.setString('key-fps', fps);
      exposureTime = root.findElements('exposuretime').single.text;
      widget.prefs.setString('key-exposure-time', exposureTime);
      warmupTime = root.findElements('warmuptime').single.text;
      widget.prefs.setString('key-warm-up-time', warmupTime);
      imageBuffer = root.findElements('imagebuffer').single.text;
      widget.prefs.setString('key-image-buffer', imageBuffer);
      imageMax = root.findElements('imagemax').single.text;
      widget.prefs.setString('key-image-max', imageBuffer);
      pixelFormat = root.findElements('pixelformat').single.text;
      widget.prefs.setString('key-pixel-format', pixelFormat);
      primarySerial = root.findElements('primaryserial').single.text;
      widget.prefs.setString('key-primary-serial', primarySerial);
      outputPath = root.findElements('outpath').single.text;
      widget.prefs.setString('key-output-path', outputPath);
    });


  }



}
