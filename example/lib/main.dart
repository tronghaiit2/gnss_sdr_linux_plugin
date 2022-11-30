import 'package:flutter/material.dart';
import 'package:new_linux_plugin_example/ui/home/Home.dart';

void main() {
   WidgetsFlutterBinding.ensureInitialized();
  runApp(const GNSS_SDR());
}

class GNSS_SDR extends StatefulWidget {
  const GNSS_SDR({super.key});

  @override
  State<GNSS_SDR> createState() => _GNSS_SDRState();
}

class _GNSS_SDRState extends State<GNSS_SDR> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Text('GNSS SDR Application'),
        // ),
        body: 
        Center(
          child: Home()
        )
      ),
    );
  }
}
