import 'dart:convert';
import 'dart:io';

class Client {

  Socket? _socket;
  Client._internal();
  static final Client _singleton = Client._internal();

  factory Client() {
    return _singleton;
  }

  Future<void> connect({
    required String ip,
    required int port,
  }) async {
    print(ip);
    _socket = await Socket.connect(ip, port);
  }

  bool? isConnected() {
    return _socket != null;
  }

  Future<void> disconnect() async {
    await _socket?.close();
  }

  String capture() {
    print("capture");
    String res = "";
    _socket?.writeln('capture');
    _socket?.listen((data) {
      res = String.fromCharCodes(data);
    });
    return res;
  }

  Future<void> setFileName(String filename) async {
    _socket?.write('filename $filename\n');
    await _socket?.flush();
  }

  Future<void> setConfiguration(String tag, String value) async {
    print('set $tag $value');
    _socket?.write('set $tag $value\n');
    await _socket?.flush();
    // await _socket?.flush();
  }

  Future<void> end() async {
    print("end");
    _socket?.write('end\n');
    await _socket?.flush();
  }

  // bad design ... should consider a workaround
  Socket? getSocket() {
    return _socket;
  }
}