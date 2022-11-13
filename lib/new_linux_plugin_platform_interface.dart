import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'new_linux_plugin_method_channel.dart';

abstract class NewLinuxPluginPlatform extends PlatformInterface {
  /// Constructs a NewLinuxPluginPlatform.
  NewLinuxPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static NewLinuxPluginPlatform _instance = MethodChannelNewLinuxPlugin();

  /// The default instance of [NewLinuxPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelNewLinuxPlugin].
  static NewLinuxPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NewLinuxPluginPlatform] when
  /// they register themselves.
  static set instance(NewLinuxPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> receiveData() {
    throw UnimplementedError('receiveData() has not been implemented.');
  }

  Future<bool?> sendData() {
    throw UnimplementedError('sendData() has not been implemented.');
  }

  Future<bool?> initMessageQueue() {
    throw UnimplementedError('initMessageQueue() has not been implemented.');
  }

  Future<bool?> endMessageQueue() {
    throw UnimplementedError('endMessageQueue() has not been implemented.');
  }
}
