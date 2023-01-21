
import 'new_linux_plugin_platform_interface.dart';

class NewLinuxPlugin {
  Future<String?> getPlatformVersion() {
    return NewLinuxPluginPlatform.instance.getPlatformVersion();
  }
  Future<String?> receiveData() {
    return NewLinuxPluginPlatform.instance.receiveData();
  }
  Future<String?> receiveCN0() {
    return NewLinuxPluginPlatform.instance.receiveCN0();
  }
  Future<String?> receiveS4() {
    return NewLinuxPluginPlatform.instance.receiveS4();
  }
  Future<bool?> sendData() {
    return NewLinuxPluginPlatform.instance.sendData();
  }
  Future<bool?> endData() {
    return NewLinuxPluginPlatform.instance.endData();
  }
  Future<bool?> initMessageQueue() {
    return NewLinuxPluginPlatform.instance.initMessageQueue();
  }
  Future<bool?> endMessageQueue() {
    return NewLinuxPluginPlatform.instance.endMessageQueue();
  }
}
