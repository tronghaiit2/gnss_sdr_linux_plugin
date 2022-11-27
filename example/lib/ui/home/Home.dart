import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_linux_plugin/new_linux_plugin.dart';
import 'package:new_linux_plugin_example/ui/common_widgets/Buttons.dart';
import 'package:new_linux_plugin_example/ui/common_widgets/NotificationDialog.dart';
import 'package:new_linux_plugin_example/utils/ColorConstant.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  late List<_ChartData> data;
  late TooltipBehavior _tooltip;

  void initData() {
    data = [
      _ChartData('01', 0),
      _ChartData('02', 0),
      _ChartData('03', 0),
      _ChartData('04', 0),
      _ChartData('05', 0),
      _ChartData('06', 0),
      _ChartData('07', 0),
      _ChartData('08', 0),
      _ChartData('09', 0),
      _ChartData('10', 0),
      _ChartData('11', 0),
      _ChartData('12', 0),
      _ChartData('13', 0),
      _ChartData('14', 0),
      _ChartData('15', 0),
      _ChartData('16', 0),
      _ChartData('17', 0),
      _ChartData('18', 0),
      _ChartData('19', 0),
      _ChartData('20', 0),
      _ChartData('21', 0),
      _ChartData('22', 0),
      _ChartData('23', 0),
      _ChartData('24', 0),
      _ChartData('25', 0),
      _ChartData('26', 0),
      _ChartData('27', 0),
      _ChartData('28', 0),
      _ChartData('29', 0),
      _ChartData('30', 0),
      _ChartData('31', 0),
      _ChartData('32', 0),
    ];
  }
  @override
  void initState() {
    super.initState();
    initPlatformState();
    initData();
    _tooltip = TooltipBehavior(enable: true);
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
    } on Exception {
      init = false;
    }
    return init;
  }

  Future<bool?> _endMessageQueue() async {
    bool end;
    try {
      end =
          await _newLinuxPlugin.endMessageQueue() ?? false;
    } on Exception {
      end = false;
    }
    return end;
  }

  static Future<String?> _receiveData() async {
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

  void sendData(String file) {
    String cmd =  "assets/tmp/$file";
    Process.run(cmd, []);
  }

  Future<bool?> _endData() async {
    bool endData;
    try {
      endData =
          await _newLinuxPlugin.endData() ?? false;
    } on Exception {
      endData = false;
    }
    return endData;
  }

  void loopReceiver() async {
    WidgetsFlutterBinding.ensureInitialized();
    initData();
    loop = true;
    int start, end, dif;
    while(loop) {
      start = DateTime.now().millisecondsSinceEpoch;
      await Future.delayed(const Duration(seconds: 0), () async {
        try {
          final String? result = await _receiveData();
          if(result != null) {
            if(result == "end") {
              isSending = false;
              loop = false;
            } else {
              Map<String, dynamic> data_list = json.decode(result);
              for(var item in data_list.entries){
                double CN0 = item.value;
                if(CN0 > 0) data[int.parse(item.key)-1].y = CN0;
              }
            }
          }
          end = DateTime.now().millisecondsSinceEpoch;
          dif = 1000 - (end - start);
          if(dif > 0) {
            Future.delayed(Duration(milliseconds:  dif), () => {
              setState(() {
                if (kDebugMode) {
                  print(dif);
                }
              })
            });
          }
        } on Exception catch (e) {
          isSending = false;
          loop = false;
        } 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
       SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'GNSS_GPS_SDR',
            ),
            Text('Running on: $_platformVersion\n', maxLines: 2,),
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
                  // Process.run("example/assets/tmp/send", []);     
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
                  // send();
                  loopReceiver();
                }
                else {
                  showConfirmDialog("Not available to send data", "Start to send data by click \"Start\" and Start GPS_SDR again", 
                  (){
                    // Process.run("assets/tmp/send", []);
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
            confirmButton("Stop receive Data", () async {
              isSending = false;
              loop = false;
              // await _endData();
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
        ),
        ),
        Expanded(
          child: Container(
              width: 1000,
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent)
              ),
            child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              title: AxisTitle(text: "Satelite")
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: "C/N0 (dB)"),
              minimum: 0, interval: 10
            ),
            legend: Legend(
              isVisible: true,
              alignment: ChartAlignment.near
            ),
            tooltipBehavior: _tooltip,
            series: <ChartSeries<_ChartData, String>>[
              ColumnSeries<_ChartData, String>(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  dataSource: data,
                  isVisible: true,
                  isVisibleInLegend: true,
                  legendItemText: "C/N0 index of\neach Satelite (dB)",
                  legendIconType: LegendIconType.rectangle,
                  // selectionBehavior: SelectionBehavior(enable: true, selectedColor: Colors.red, unselectedColor: Colors.blueAccent),
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  name: 'dB',
                  color: Colors.blueAccent)
            ]),
          ),
        )
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
 
  late String x;
  late double y;
}