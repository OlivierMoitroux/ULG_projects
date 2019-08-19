import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

/// Singleton to access the secured storage utility.
class SecuredStorageSingleton {
  static final FlutterSecureStorage _singleton = new FlutterSecureStorage();

  SecuredStorageSingleton();

  static FlutterSecureStorage getInstance() {
    return _singleton;
  }

  static Future<String> getSession(){
    return _singleton.read(key: "session");
  }
}