import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'new_linux_plugin_platform_interface.dart';

/// An implementation of [NewLinuxPluginPlatform] that uses method channels.
class MethodChannelNewLinuxPlugin extends NewLinuxPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('new_linux_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> receiveData() async {
    final data = await methodChannel.invokeMethod<String>('receiveData');
    return data;
  }

  @override
  Future<bool?> sendData() async {
    final send = await methodChannel.invokeMethod<bool>('sendData');
    return send;
  }

  @override
  Future<bool?> endData() async {
    final end = await methodChannel.invokeMethod<bool>('endData');
    return end;
  }

  @override
  Future<bool?> initMessageQueue() async {
    final init = await methodChannel.invokeMethod<bool>('initMessageQueue');
    return init;
  }
  
  @override
  Future<bool?> endMessageQueue() async {
    final end = await methodChannel.invokeMethod<bool>('endMessageQueue');
    return end;
  }
}