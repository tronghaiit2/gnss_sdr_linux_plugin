
import 'new_linux_plugin_platform_interface.dart';

class NewLinuxPlugin {
  Future<String?> getPlatformVersion() {
    return NewLinuxPluginPlatform.instance.getPlatformVersion();
  }
  Future<String?> receiveData() {
    return NewLinuxPluginPlatform.instance.receiveData();
  }
  Future<bool?> sendData() {
    return NewLinuxPluginPlatform.instance.sendData();
  }
  Future<bool?> initMessageQueue() {
    return NewLinuxPluginPlatform.instance.initMessageQueue();
  }
  Future<bool?> endMessageQueue() {
    return NewLinuxPluginPlatform.instance.endMessageQueue();
  }
}
