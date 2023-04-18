import 'dart:io';

import 'package:ssh2/ssh2.dart';

class SSHConnection {
  late SSHClient _client;
  String result = "";
  int mins = 0;
  int secs = 0;
  int counter = 0;
  bool flag = false;
  SSHConnection._internal();
  static final SSHConnection _singleton = SSHConnection._internal();

  factory SSHConnection() {
    return _singleton;
  }

  Future<String?> connect({
    required String host,
    required int port,
    required String username,
    required String passwordOrKey,
  }) async {
    _client = SSHClient(
        host: host,
        port: port,
        username: username,
        passwordOrKey: passwordOrKey);
    var res = await _client.connect();
    return res;
  }

  Future<String?> start(String filename, int mins, int secs) async {
    return _client.startShell(
        callback: (dynamic res) async {
          print(res);
          if (res == "Provide the name of the trial. [ex: test1] : \n") {
            await _executeCommand('$filename\r');
          }
          if (res == '*** CAMERAS READY ***\n') {
            if (counter < 3) {
              counter++;
              print(counter);
            } else {
              sleep(Duration(minutes: mins, seconds: secs));
              print("here");
              await _executeCommand('export DISPLAY=:0.0 && xdotool key Escape+Return\r');
            }
          }
        }
    );
  }

  Future<String?> _executeCommand(String command) async {
    final result = await _client.writeToShell(command);
    return result;
  }

  Future<bool> isConnected() async {
    return await _client.isConnected();
  }

  Future<void> disconnect() async {
    await _client.disconnect();
  }

  Future<String?> moveTo(String path) async {
    return _executeCommand('cd $path\n');
  }

  Future<String?> startRecording() async {
    return await _executeCommand('./multicamera_capture\r');
  }

  Future<String?> setName(String filename) async {
    // return _executeCommand('$filename\r');
  }

}