import 'package:ssh2/ssh2.dart';

class SSHConnection {
  late SSHClient _client;
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
      return await _client.connect();
  }

  Future<String?> _executeCommand(String command) async {
    final result = await _client.execute(command);
    return result;
  }

  Future<bool> isConnected() async {
    return await _client.isConnected();
  }

  Future<void> disconnect() async {
    await _client.disconnect();
  }

  Future<String?> moveTo(String path) async {
    return _executeCommand('cd $path');
  }

  Future<String?> startRecording() async {
    return _executeCommand('echo echochenggong');
  }

  Future<String?> endRecording() async {
    return _executeCommand('ipconfig');
  }

}