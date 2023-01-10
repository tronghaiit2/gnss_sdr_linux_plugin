import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:new_linux_plugin/new_linux_plugin.dart';
import 'package:new_linux_plugin/new_linux_plugin_platform_interface.dart';
import 'package:new_linux_plugin/new_linux_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNewLinuxPluginPlatform
    with MockPlatformInterfaceMixin
    implements NewLinuxPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
  
  @override
  Future<String?> receiveData() => Future.value('json_test');
  @override
  Future<String?> receiveCN0() => Future.value('json_test');
  @override
  Future<String?> receiveSIRaw() => Future.value('json_test');
    
  @override
  Future<bool?> initMessageQueue() => Future.value(true);

  @override
  Future<bool?> endMessageQueue() => Future.value(true);
  
  @override
  Future<bool?> endData() => Future.value(true);
  
  @override
  Future<bool?> sendData() => Future.value(true);

}

void main() {
  final NewLinuxPluginPlatform initialPlatform = NewLinuxPluginPlatform.instance;

  test('$MethodChannelNewLinuxPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNewLinuxPlugin>());
  });

  test('getPlatformVersion', () async {
    NewLinuxPlugin newLinuxPlugin = NewLinuxPlugin();
    MockNewLinuxPluginPlatform fakePlatform = MockNewLinuxPluginPlatform();
    NewLinuxPluginPlatform.instance = fakePlatform;

    expect(await newLinuxPlugin.getPlatformVersion(), '42');
  });

  test('sendData', () async {
    NewLinuxPlugin newLinuxPlugin = NewLinuxPlugin();
    MockNewLinuxPluginPlatform fakePlatform = MockNewLinuxPluginPlatform();
    NewLinuxPluginPlatform.instance = fakePlatform;

    expect(await newLinuxPlugin.sendData(), true);
  });

  test('endData', () async {
    NewLinuxPlugin newLinuxPlugin = NewLinuxPlugin();
    MockNewLinuxPluginPlatform fakePlatform = MockNewLinuxPluginPlatform();
    NewLinuxPluginPlatform.instance = fakePlatform;

    expect(await newLinuxPlugin.endData(), true);
  });

  test('receiveData', () async {
    NewLinuxPlugin newLinuxPlugin = NewLinuxPlugin();
    MockNewLinuxPluginPlatform fakePlatform = MockNewLinuxPluginPlatform();
    NewLinuxPluginPlatform.instance = fakePlatform;

    expect(await newLinuxPlugin.receiveData(), 'json_test');
  });

  test('receiveCN0', () async {
    NewLinuxPlugin newLinuxPlugin = NewLinuxPlugin();
    MockNewLinuxPluginPlatform fakePlatform = MockNewLinuxPluginPlatform();
    NewLinuxPluginPlatform.instance = fakePlatform;

    expect(await newLinuxPlugin.receiveCN0(), 'json_test');
  });

  test('receiveSIRaw', () async {
    NewLinuxPlugin newLinuxPlugin = NewLinuxPlugin();
    MockNewLinuxPluginPlatform fakePlatform = MockNewLinuxPluginPlatform();
    NewLinuxPluginPlatform.instance = fakePlatform;

    expect(await newLinuxPlugin.receiveSIRaw(), 'json_test');
  });


  test('initMessageQueue', () async {
    NewLinuxPlugin newLinuxPlugin = NewLinuxPlugin();
    MockNewLinuxPluginPlatform fakePlatform = MockNewLinuxPluginPlatform();
    NewLinuxPluginPlatform.instance = fakePlatform;

    expect(await newLinuxPlugin.initMessageQueue(), true);
  });

  test('endMessageQueue', () async {
    NewLinuxPlugin newLinuxPlugin = NewLinuxPlugin();
    MockNewLinuxPluginPlatform fakePlatform = MockNewLinuxPluginPlatform();
    NewLinuxPluginPlatform.instance = fakePlatform;

    expect(await newLinuxPlugin.endMessageQueue(), true);
  });
}
