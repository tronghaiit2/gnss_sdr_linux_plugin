import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_linux_plugin/new_linux_plugin.dart';
import 'package:new_linux_plugin_example/models/GnssSdrController.dart';
import 'package:new_linux_plugin_example/ui/MultiChoice.dart';
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
  late GnssSdrController gnssSdrController;
  late bool messageQueueAvailable = false;
  late bool loop = false;
  late bool isSending = false;

  late List<List<_ChartData>> data;
  late TooltipBehavior _tooltip;

  late List<String> gpsPRNSelectedList;
  late int itemsSelected = 1;

  void initData() {
    DateTime dateTime = DateTime.now();
    data = [[_ChartData(dateTime, 0)], 
    [], [], [], [], [], [], [], []];
  }
  
  @override
  void initState() {
    super.initState();
    initData();
    gnssSdrController = GnssSdrController(newLinuxPlugin: _newLinuxPlugin);
    _tooltip = TooltipBehavior(enable: true);
  }

  void sendData(String file) {
    String cmd =  "assets/tmp/$file";
    Process.run(cmd, []);
  }


  void loopReceiver() async {
    initData();
    loop = true;
    int errorCount = 0;
    // int start, end, dif;
    while(loop) {
      gnssSdrController.sendData();
      // start = DateTime.now().millisecondsSinceEpoch;
      await Future.delayed(const Duration(milliseconds: 975), () async {
        try {
          // final String? result = await _receiveData();
          // final String? result = await _receiveCN0();
          // final String? result = await _receivePromptI();
          final String? result = await gnssSdrController.receiveS4();
          DateTime dateTime = DateTime.now();
          if(result != null) {
            if(result == "end") {
              errorCount++;
              if(errorCount > 4) {
                isSending = false;
                loop = false;
                // ignore: use_build_context_synchronously
                showWarningDialog("Can not receive GPS signal!", context);
              }
            } else {
              errorCount = 0;
              Map<String, dynamic> data_list = json.decode(result);
              while(data[0].length > 60) {
                for(int i = 0; i < itemsSelected; i++){
                  data[i].removeAt(0);
                }
              }
              
              for(int i = 1; i < itemsSelected; i++){
                String prn = int.parse(gpsPRNSelectedList[i-1]).toString();

                if(data_list[prn] == null) {
                  if (kDebugMode) {
                    print("data" + data_list[prn].toString());
                  }
                  data[i].add(_ChartData(dateTime, 0));
                } else {
                  if (kDebugMode) {
                    print("data" + data_list[prn].toString());
                  }
                  data[i].add(_ChartData(dateTime, data_list[prn]));
                }
              }

              // for(int i = 1; i < itemsSelected; i++){
              //   if(data_list[gpsPRNSelectedList[i-1]] == null || data_list[gpsPRNSelectedList[i-1]] < 0) {
              //     data[i].add(_ChartData(dateTime, 0));
              //   } else {
              //     data[i].add(_ChartData(dateTime, data_list[gpsPRNSelectedList[i-1]]));
              //   }
              // }
              
              setState(() {
                if(data[1].length > 1) {
                  data[0].add(_ChartData(dateTime, 0));
                }
              });
            }
          } else {
            errorCount++;
            if(errorCount > 4) {
              isSending = false;
              loop = false;
              // ignore: use_build_context_synchronously
              showWarningDialog("Can not receive GPS signal!", context);
            }
          }
          // end = DateTime.now().millisecondsSinceEpoch;
          // dif = 1000 - (end - start);
          // if(dif > 0) {
          //   Future.delayed(Duration(milliseconds:  dif), () => {
          //   });
          // }
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
                gnssSdrController.initMessageQueue();
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
                    // gnssSdrController.sendData();
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
                      gnssSdrController.initMessageQueue();
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
                gnssSdrController.endData();
              }),
              SizedBox(height: 20,),
              confirmButton("Clear MessageQueue", (){
                if(loop) {
                  showWarningDialog("Please waiting for end of Message Queue, then clear queue", context);
                }
                else {
                  if(messageQueueAvailable) {
                    gnssSdrController.endMessageQueue();
                    messageQueueAvailable = false;
                  }
                }
              }),
            ],
          ),
        ),
        Expanded(
          child: diagram(),
          // child: Column(
          //   crossAxisAlignment: CrossAxisAlignment.stretch,
          //   children: [
          //     Row(
          //       children: [
          //         Container(
          //           height: 300,
          //           width: 1280,
          //           decoration: BoxDecoration(
          //             border: Border.all(color: Colors.blueGrey, width: 2)
          //           ),
          //           child: MultiChoice(
          //             onSelectParam: (HashSet<String> selectedList) {
          //               // do something with param
          //               gpsPRNSelectedList = selectedList.toList();
          //               itemsSelected = gpsPRNSelectedList.length + 1;
          //               gpsPRNSelectedList.sort();
          //               print(gpsPRNSelectedList.toString());
          //             }
          //           ),
          //         ),
          //       ],
          //     ),
          //     Expanded(
          //       child: Container(
          //         width: 1000,
          //         margin: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0),
          //         padding: const EdgeInsets.all(5.0),
          //         decoration: BoxDecoration(
          //           border: Border.all(color: Colors.blueAccent)
          //         ),
          //         child: SfCartesianChart(
          //         plotAreaBorderWidth: 0.9,
          //         primaryXAxis: DateTimeAxis(
          //           title: AxisTitle(text: "Times"),
          //           intervalType: DateTimeIntervalType.seconds,
          //           minimum: data_1.elementAt(0).x,
          //         ),
          //         primaryYAxis: NumericAxis(
          //           title: AxisTitle(text: "C/N0 (dB)"),
          //           minimum: 30, interval: 10
          //         ),
          //         legend: Legend(
          //           isVisible: true,
          //           alignment: ChartAlignment.near
          //         ),
          //         tooltipBehavior: _tooltip,
          //         series: 
          //         itemsSelected < 2 ? 
          //         <ChartSeries<_ChartData, DateTime>>[
          //           LineSeries<_ChartData, DateTime>(
          //               dataSource: data[0],
          //               isVisible: true,
          //               isVisibleInLegend: true,
          //               legendItemText: "C/N0 index of\neach Satelite (dB)",
          //               legendIconType: LegendIconType.rectangle,
          //               // selectionBehavior: SelectionBehavior(enable: true, selectedColor: Colors.red, unselectedColor: Colors.blueAccent),
          //               xValueMapper: (_ChartData data, _) => data.x,
          //               yValueMapper: (_ChartData data, _) => data.y,
          //               name: 'dB',),
          //         ] : 
          //         <ChartSeries<_ChartData, DateTime>>[
          //           for(int i = 1; i < itemsSelected; i++) 
          //           LineSeries<_ChartData, DateTime>(
          //               dataSource: data[i],
          //               isVisible: true,
          //               isVisibleInLegend: true,
          //               legendItemText: "C/N0 index of\nSatelite ${gpsPRNSelectedList[i-1]} (dB)",
          //               legendIconType: LegendIconType.rectangle,
          //               // selectionBehavior: SelectionBehavior(enable: true, selectedColor: Colors.red, unselectedColor: Colors.blueAccent),
          //               xValueMapper: (_ChartData data, _) => data.x,
          //               yValueMapper: (_ChartData data, _) => data.y,
          //               name: 'dB',),
          //         ]
          //         ),
          //       ),
          //     )
          //   ],
          // )
        ),
      ],
    );
  }

  Widget diagram() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select GPS Satellite"),
        centerTitle: false,
        toolbarHeight: 50,
      ),
      drawer: drawer(),
      body: Container(
          width: 1000,
          margin: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0),
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent)
          ),
          child: SfCartesianChart(
          plotAreaBorderWidth: 0.9,
          primaryXAxis: DateTimeAxis(
            title: AxisTitle(text: "Times"),
            intervalType: DateTimeIntervalType.seconds,
            minimum: data[0].elementAt(0).x,
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: "C/N0 (dB)"),
            // maximum: 8000000000000,
            // minimum: -1000000000000
            // interval: 10
          ),
          legend: Legend(
            isVisible: true,
            alignment: ChartAlignment.near
          ),
          tooltipBehavior: _tooltip,
          series: 
          itemsSelected < 2 ? 
          <ChartSeries<_ChartData, DateTime>>[
            LineSeries<_ChartData, DateTime>(
                dataSource: data[0],
                isVisible: true,
                isVisibleInLegend: true,
                legendItemText: "SI Raw index of\neach Satelite",
                legendIconType: LegendIconType.rectangle,
                // selectionBehavior: SelectionBehavior(enable: true, selectedColor: Colors.red, unselectedColor: Colors.blueAccent),
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                animationDuration: 0,
                name: 'dB',),
          ] : 
          <ChartSeries<_ChartData, DateTime>>[
            for(int i = 1; i < itemsSelected; i++) 
            LineSeries<_ChartData, DateTime>(
                dataSource: data[i],
                isVisible: true,
                isVisibleInLegend: true,
                legendItemText: "SI Raw index of\nSatelite ${gpsPRNSelectedList[i-1]}",
                legendIconType: LegendIconType.rectangle,
                // selectionBehavior: SelectionBehavior(enable: true, selectedColor: Colors.red, unselectedColor: Colors.blueAccent),
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                animationDuration: 0,
                name: 'dB',),
          ]
          ),
        ),
    );
  }

  Widget drawer() {
    return Container(
        height: 300,
        width: 1280,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey, width: 2)
        ),
        child: MultiChoice(
          onSelectParam: (HashSet<String> selectedList) {
            // do something with param
            gpsPRNSelectedList = selectedList.toList();
            itemsSelected = gpsPRNSelectedList.length + 1;
            gpsPRNSelectedList.sort();
            Navigator.pop(context);
            print(gpsPRNSelectedList.toString());
          }
        ),
      );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  late DateTime x;
  late double y;
}