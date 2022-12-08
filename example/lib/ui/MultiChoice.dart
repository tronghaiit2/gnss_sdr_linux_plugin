import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:new_linux_plugin_example/ui/common_widgets/NotificationDialog.dart';
import 'package:new_linux_plugin_example/utils/ColorConstant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MultiChoice(
        onSelectParam: (HashSet<String> param) {
            // do something with param
        }
      ),
    );
  }
}

class MultiChoice extends StatefulWidget {
  Function(HashSet<String>) onSelectParam;
  MultiChoice({Key? key, required this.onSelectParam}) : super(key: key);

  @override
  State<MultiChoice> createState() => _MultiChoiceState();
}

class _MultiChoiceState extends State<MultiChoice> {
  List<String> gpsPRNList = [
    "01", "02", "03", "04", "05", "06", "07", "08",
    "09", "10", "11", "12", "13", "14", "15", "16",
    "17", "18", "19", "20", "21", "22", "23", "24",
    "25", "26", "27", "28", "29", "30", "31", "32"
  ];
  int maxSelections = 8;

  HashSet<String> selectedItem = HashSet<String>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        leadingWidth: 150,
        leading: Row(
          children: [
            IconButton(
              onPressed: () {
                selectedItem.clear();
                setState(() {});
              },
              icon: Icon(Icons.close)
            ),
            Text(getSelectedItemCount()),
          ],
        ),
        title: Text("Select GPS Satellite"),
        actions: [
          // Visibility(
          //     visible: selectedItem.isNotEmpty,
          //     child: 
              Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppColors.orange,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: AppColors.green,
                    splashColor: AppColors.green,
                    borderRadius: BorderRadius.circular(5),
                    onTap: () => {
                      widget.onSelectParam(selectedItem)
                    },
                    child: Row(children: [
                      SizedBox(
                        width: 20,
                      ),
                      Icon(Icons.check_rounded),
                      SizedBox(
                        width: 10,
                      ),
                       Text(
                        selectedItem.isNotEmpty ? "Confirm" : "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      SizedBox(
                        width: 20,
                      )
                    ],),
                  ),
                ),
              ),
            // ),
          // IconButton(
          //   icon: Icon(
          //     Icons.select_all,
          //     color: selectedItem.length == gpsPRNList.length
          //         ? Colors.black
          //         : Colors.white,
          //   ),
          //   onPressed: () {
          //     if (selectedItem.length == gpsPRNList.length) {
          //       selectedItem.clear();
          //     } else {
          //       for (int index = 0; index < gpsPRNList.length; index++) {
          //         selectedItem.add(gpsPRNList[index]);
          //       }
          //     }
          //     setState(() {});
          //   },
          // )
        ],
      ),
      body: Container(
        width: 1280,
        alignment: Alignment.center,
        child: GridView.count(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        shrinkWrap: true,
        primary: false,
        childAspectRatio: 3,
        crossAxisCount: 8,
        children: gpsPRNList.map((String gpsPRN) {
        return Card(
            elevation: 5,
            margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            child: getListItem(gpsPRN),
            );
          }).toList(),
        ),
      )
    );
  }

  String getSelectedItemCount() {
    return selectedItem.isNotEmpty
        ? selectedItem.length.toString() + " item selected"
        : "No item selected";
  }

  void doMultiSelection(String gpsPRN) {
      if (selectedItem.contains(gpsPRN)) {
        selectedItem.remove(gpsPRN);
      } else {
        if(selectedItem.length < 8) {
          selectedItem.add(gpsPRN);
        }
        else {
          showWarningDialog("You can select max 8 Satellite!", context);
        }
      }
      setState(() {});
  }

  InkWell getListItem(String gpsPRN) {
    return InkWell(
        onTap: () {
          doMultiSelection(gpsPRN);
        },
        child:
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 10,
              ),
              Icon(
                selectedItem.contains(gpsPRN)
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 24,
                color: Colors.red,
              ),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                width: 40,
                height: 24.0,
                child: Text(
                  gpsPRN,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
            ],
          ),
        );
  }
}