import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_linux_plugin/new_linux_plugin_method_channel.dart';

void main() {
  MethodChannelNewLinuxPlugin platform = MethodChannelNewLinuxPlugin();
  const MethodChannel channel = MethodChannel('new_linux_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
