import 'package:air_brother/air_brother.dart';
import 'package:brotherquickstart/util/navigation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'dart:async';

class BrotherWifiScanner extends StatefulWidget {
  final String title;

  const BrotherWifiScanner({Key? key, required this.title}) : super(key: key);
  @override
  State<BrotherWifiScanner> createState() => _BrotherWifiScannerState();
  static  Connector? connector;

  static Future<void> scan(File file) async {
    debugPrint("BrotherWifiScanner: static void scan");
  }
}

class _BrotherWifiScannerState extends State<BrotherWifiScanner> {
  List<Connector> _connectors = List.empty(growable: true);
  bool isLoading = true;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      loadPage();
    });
  }


  @override
  Widget build(BuildContext context) {
    if (!mounted) return Container();
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: buildDrawer(),
        body: const SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_connectors.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: buildDrawer(),
        body: const SafeArea(
          child: Center(
            child: Text("No Scanners printers found"),
          ),
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: buildDrawer(),
      body: SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _connectors.length,
          itemBuilder: (BuildContext context, int index) {
            Connector oConnector = _connectors[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              shadowColor: Colors.black,
              // elevation: 11,
              borderOnForeground: false,
              color: Colors.white70,
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.scanner)),
                    title: Text(oConnector.getModelName()),
                    subtitle: Text("isScanSupported: ${oConnector.isScanSupported()}"),
                    onTap: () {
                      selectScanner(oConnector);
                    },
                    trailing: buildTrailingIcon(oConnector),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Icon buildTrailingIcon(Connector oConnector) {
    if (BrotherWifiScanner.connector == null) {
      return const Icon(Icons.no_cell_outlined);
    }
    if (oConnector.getModelName().compareTo(BrotherWifiScanner.connector!.getModelName()) == 0) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.no_cell_outlined);
  }
  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Shifting
      backgroundColor: Colors.blue, // <-- This works for fixed
      selectedItemColor: Colors.black,
      // unselectedItemColor: Colors.grey,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.wifi),
          label: 'Printers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bluetooth),
          label: 'Printers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.scanner),
          label: 'Scanners',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
      ],
      currentIndex: _selectedIndex,
      // selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );
  }

  Future<void> loadPage() async {
    debugPrint("BrotherWifiScanner: loadPage");
    setState(() {
      _connectors = List.empty(growable: true);
      isLoading = true;
    });

    _connectors = await AirBrother.getNetworkDevices(5000);
    setState(() {
      _connectors;
      isLoading = false;
    });
    debugPrint("BrotherWifiScanner: loadPage: _netPrinterList.length: ${_connectors.length}");
  }

  void selectScanner(Connector oConnector) {
    debugPrint("BrotherWifiScanner: selectPrinter: NetPrinter: $oConnector");
    BrotherWifiScanner.connector = oConnector;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
            'Wifi Scanner is now active',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amberAccent),
    );
    // Navigation().goHome(context);
    _scanFiles(oConnector);

  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 0) {
      Navigation().openBrotherWifiPrinter(context);
    }
    if (_selectedIndex == 1) {
      Navigation().openBrotherBluetoothPrinter(context);
    }
    if (_selectedIndex == 2) {
      Navigation().openBrotherBrotherWifiScanner(context);
    }
    if (_selectedIndex == 3) {
      Navigation().goHome(context);
    }
  }

  buildDrawer() {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Image.asset("assets/logo2.png", height: 150),
          ),
          Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                height: 5,
                color: Colors.black,
              ),
              TextButton.icon(
                label: const Text("Home"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigation().goHome(context);
                },
                icon: const Icon(Icons.home),
              ),
              TextButton.icon(label: const Text("Wifi Printers"), onPressed: () {Navigator.pop(context);Navigation().openBrotherWifiPrinter(context);}, icon: const Icon(Icons.wifi),),
              TextButton.icon(label: const Text("Bluetooth Printers"), onPressed: () {Navigator.pop(context);Navigation().openBrotherBluetoothPrinter(context);}, icon: const Icon(Icons.bluetooth),),
              TextButton.icon(label: const Text("Wifi Scanner"), onPressed: () {Navigator.pop(context);Navigation().openBrotherBrotherWifiScanner(context);}, icon: const Icon(Icons.scanner),),

            ],
          ),
        ],
      ),
    );
  }

  void _scanFiles(Connector connector) async {
    List<String> outScannedPaths = [];
    ScanParameters scanParams = ScanParameters();
    scanParams.documentSize = MediaSize.A6;
    JobState jobState = await connector.performScan(scanParams, outScannedPaths);
    debugPrint("BrotherWifiScanner: _scanFiles: JobState: $jobState");
    // the output has an extension of jqp but it is really a jpg
    // just rename the file to ${filename}.jpg
    debugPrint("BrotherWifiScanner: _scanFiles: Files Scanned: $outScannedPaths");
    debugPrint("BrotherWifiScanner: _scanFiles: here is your image ->>>>> : $outScannedPaths");
    debugPrint("BrotherWifiScanner: _scanFiles: here is your image ->>>>> : $outScannedPaths");
    debugPrint("BrotherWifiScanner: _scanFiles: here is your image ->>>>> : $outScannedPaths");
    debugPrint("BrotherWifiScanner: _scanFiles: here is your image ->>>>> : $outScannedPaths");
    debugPrint("BrotherWifiScanner: _scanFiles: here is your image ->>>>> : $outScannedPaths");
    debugPrint("BrotherWifiScanner: _scanFiles: here is your image ->>>>> : $outScannedPaths");
    debugPrint("BrotherWifiScanner: _scanFiles: here is your image ->>>>> : $outScannedPaths");
    setState(() {
      // _scannedFiles = outScannedPaths;
    });
  }
}
