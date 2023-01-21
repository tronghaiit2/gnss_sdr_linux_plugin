import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:new_linux_plugin/new_linux_plugin.dart';

class GnssSdrController {
  late NewLinuxPlugin _newLinuxPlugin;

  GnssSdrController({required NewLinuxPlugin newLinuxPlugin}) {
    this._newLinuxPlugin = newLinuxPlugin;
  }

  Future<String> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _newLinuxPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    return platformVersion;
  }

  Future<bool?> initMessageQueue() async {
    bool init;
    try {
      init =
          await _newLinuxPlugin.initMessageQueue() ?? false;
    } on Exception {
      init = false;
    }
    return init;
  }

  Future<bool?> endMessageQueue() async {
    bool end;
    try {
      end =
          await _newLinuxPlugin.endMessageQueue() ?? false;
    } on Exception {
      end = false;
    }
    return end;
  }

  Future<String?> receiveData() async {
    String? receiveData;
    try {
      receiveData =
          await _newLinuxPlugin.receiveData();
    } on Exception {
      if (kDebugMode) {
        print("exception");
      }
    }
    return receiveData;
  }
    void sendData() async {
    _newLinuxPlugin.sendData();
  }

  Future<bool?> endData() async {
    bool endData;
    try {
      endData =
          await _newLinuxPlugin.endData() ?? false;
    } on Exception {
      endData = false;
    }
    return endData;
  }

  Future<String?> receiveCN0() async {
    String? receiveData;
    try {
      receiveData =
          await _newLinuxPlugin.receiveCN0();
    } on Exception {
      if (kDebugMode) {
        print("exception");
      }
    }
    return receiveData;
  }

  Future<String?> receiveS4() async {
    String? receiveData;
    try {
      receiveData =
          await _newLinuxPlugin.receiveS4();
    } on Exception {
      if (kDebugMode) {
        print("exception");
      }
    }
    return receiveData;
  }

}