import 'package:ssh2/ssh2.dart';

class SSHConnection {
  late SSHClient _client;
  String result = "";
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
    _client.startShell(
      callback: (dynamic res) {
        print(result + res);
      }
    );

    return res;
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

  Future<String?> startRecording(String filename) async {
    await _executeCommand('./multicamera_capture\n');
    return _executeCommand('$filename\n');
  }

  Future<String?> endRecording() async {
    return _executeCommand('1\n');
  }

}