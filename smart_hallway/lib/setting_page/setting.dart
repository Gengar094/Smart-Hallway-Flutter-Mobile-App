
import 'package:smart_hallway/main.dart';
import 'package:xml/xml.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

import '../util/client.dart';
import '../util/util.dart';
import 'customize_input_field.dart';

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
      if (widget.prefs.getBool('key-connected') ?? false) {
        io.disconnect().then((value) {
          widget.prefs.setBool('key-connected', false);
        });
      }
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
                      showError('Not connected to server.');
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
                      showError('Not connected to server.');
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
                      showError('Not connected to server.');
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
                      showError('Not connected to server.');
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
              CustomTextInputField(
                title: 'Width',
                value: width,
                showDialog: () {
                  return showDialogLogic();
                },
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
              CustomTextInputField(
                title: 'Height',
                value: height,
                showDialog: () {
                  return showDialogLogic();
                },
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
                      showError('Not connected to server.');
                    }
                  });
                },
              ),
              const Divider(
                thickness: .5,
                height: 0,
              ),
              CustomTextInputField(
                title: 'FPS',
                value: fps,
                showDialog: () {
                  return showDialogLogic();
                },
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
              CustomTextInputField(
                title: 'Exposure time',
                value: exposureTime,
                showDialog: () {
                  return showDialogLogic();
                },
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
              CustomTextInputField(
                title: 'Warmup time',
                value: warmupTime,
                showDialog: () {
                  return showDialogLogic();
                },
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
              CustomTextInputField(
                title: 'Image buffer',
                value: imageBuffer,
                showDialog: () {
                  return showDialogLogic();
                },
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
              CustomTextInputField(
                title: 'Image max',
                value: imageMax,
                showDialog: () {
                  return showDialogLogic();
                },
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
              CustomTextInputField(
                title: 'Pixel format',
                value: pixelFormat,
                showDialog: () {
                  return showDialogLogic();
                },
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
              CustomTextInputField(
                title: 'Primary serial',
                value: primarySerial,
                showDialog: () {
                  return showDialogLogic();
                },
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
              CustomTextInputField(
                title: 'Output Path',
                value: outputPath,
                showDialog: () {
                  return showDialogLogic();
                },
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

  bool showDialogLogic() {
    if (widget.prefs.getBool('key-connected') != null) {
      if (!widget.prefs.getBool('key-connected')!) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  void showError (String msg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(
              msg),
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
                showError('Not able to connect, please make sure the server is running on the proper ip and port.');
              }
            });
          } catch (e) {
            showError('Not able to connect, please make sure the server is running on the proper ip and port.');
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
      if (xmlStr == 'file is not found') {
        showError('Configuration file is not found. Use the default configuration now. Please make sure the SETTING_PATH in the server is properly set');
      } else {
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
        widget.prefs.setString('key-image-max', imageMax);
        pixelFormat = root.findElements('pixelformat').single.text;
        widget.prefs.setString('key-pixel-format', pixelFormat);
        primarySerial = root.findElements('primaryserial').single.text;
        widget.prefs.setString('key-primary-serial', primarySerial);
        outputPath = root.findElements('outpath').single.text;
        widget.prefs.setString('key-output-path', outputPath);
      }
    });


  }



}
