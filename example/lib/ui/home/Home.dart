import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_linux_plugin/new_linux_plugin.dart';
import 'package:new_linux_plugin_example/ui/common_widgets/Buttons.dart';
import 'package:new_linux_plugin_example/ui/common_widgets/NotificationDialog.dart';
import 'package:new_linux_plugin_example/utils/ColorConstant.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _platformVersion = 'Unknown';
  static final _newLinuxPlugin = NewLinuxPlugin();
  late bool messageQueueAvailable = false;
  late bool loop = false;
  late bool isSending = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _newLinuxPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<bool?> _initMessageQueue() async {
    bool init;
    try {
      init =
          await _newLinuxPlugin.initMessageQueue() ?? false;
    } on PlatformException {
      init = false;
    }
    return init;
  }

  Future<bool?> _endMessageQueue() async {
    bool end;
    try {
      end =
          await _newLinuxPlugin.endMessageQueue() ?? false;
    } on PlatformException {
      end = false;
    }
    return end;
  }

  Future<bool?> _sendData() async {
    bool sendData;
    try {
      sendData =
          await _newLinuxPlugin.sendData() ?? false;
    } on PlatformException {
      sendData = false;
    }
    return sendData;
  }

  Future<String?> _receiveData() async {
    String receiveData;
    try {
      receiveData =
          await _newLinuxPlugin.receiveData() ?? 'No data sent';
    } on PlatformException {
      receiveData = 'No data sent';
    }
    return receiveData;
  }

  void loopReceiver() async {
    String? result = "";
    loop = true;
    while(loop) {
      await Future.delayed(Duration(milliseconds: 500), () async {
        if (kDebugMode) {
          result = await _receiveData();
          print(result);
        }
      });
      if(result == "end") {
        isSending = false;
        loop = false;
      }
    }
  }

  static Future<bool> send(int val) async {
    bool sendData;
    try {
      sendData =
          await _newLinuxPlugin.sendData() ?? false;
    } on PlatformException {
      sendData = false;
    }
    return sendData;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'GNSS_GPS_SDR',
          ),
          Text('Running on: $_platformVersion\n'),
          SizedBox(height: 20,),
          confirmButton("Init MessageQueue", (){
            _initMessageQueue();
            messageQueueAvailable = true;
          }),
          SizedBox(height: 20,),
          confirmButton("Send Data", () async {
            if(loop) {
              showWarningDialog("Please waiting for end of data before", context);
            }
            else {
              if(messageQueueAvailable) {
                Process.run("tmp/./send", []);
                isSending = true;
              }
            }
          }),
          SizedBox(height: 20,),
          confirmButton("Start GPS_SDR", (){
              if(loop) {
              showWarningDialog("Please waiting for end of Message Queue, then start again", context);
            }
            else {
            if(messageQueueAvailable) {
              if(isSending) {
                loopReceiver();
              }
              else {
                showConfirmDialog("Not available to send data", "Start to send data by click \"Start\" and Start GPS_SDR again", 
                (){
                  Process.run("tmp/./send", []);
                  isSending = true;
                }, 
                (){}, context, "Start", "Cancel");
              }
            }
            else {
              showConfirmDialog("Please Init MessageQueue", "init MessageQueue by click \"Init\" and Start GPS_SDR again", 
              (){
                if(!messageQueueAvailable) {
                  _initMessageQueue();
                  messageQueueAvailable = true; 
                }
              }, 
              (){}, context, "Init", "Cancel");
            }
            }
          }),
          SizedBox(height: 20,),
          confirmButton("Clear MessageQueue", (){
            if(loop) {
              showWarningDialog("Please waiting for end of Message Queue, then clear queue", context);
            }
            else {
              if(messageQueueAvailable) {
                _endMessageQueue();
                messageQueueAvailable = false;
              }
            }
          }),
        ],
      )
    );
  }
}
