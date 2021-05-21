import 'package:flutter/services.dart';
import 'dart:typed_data';

class Encryption {
  static const platform = const MethodChannel('app.sideswap.io/encryption');

  Future<Uint8List> encrypt(String data) async {
    Uint8List dataCopy = Uint8List.fromList(data.codeUnits);
    var result = await _process('encrypt', dataCopy);
    return result;
  }

  Future<String> decrypt(Uint8List data) async {
    Uint8List result = await _process('decrypt', data);
    return String.fromCharCodes(result);
  }

  Future<Uint8List> _process(String methodName, Uint8List data) async {
    try {
      Uint8List result = await platform.invokeMethod(methodName, data);
      return result;
    } on PlatformException catch (e) {
      print('failed: $e');
    } on MissingPluginException catch (e) {
      print('not avaialble: $e');
    }
    return null;
  }
}
