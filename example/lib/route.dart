/*This file contains all the routes for this application.*/
import 'package:flutter/material.dart';
import 'package:new_linux_plugin_example/ui/home/Home.dart';

class Routes {
  Routes._();

  //static variables
  static const String home = "/home";

  // static const String history = "/history";

  static final routes = <String, WidgetBuilder>{

    home: (BuildContext context) => Home(),

    // history: (BuildContext context) => History(),
  };
}
