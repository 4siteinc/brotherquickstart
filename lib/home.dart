import 'dart:io';

import 'package:brotherquickstart/util/navigation.dart';
import 'package:brotherquickstart/util/permission_util.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  final String title;
  const Home({Key? key, required this.title}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  List<Permission> _permissionList = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    loadPage();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionList.isEmpty && Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
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
              icon: Icon(Icons.image),
              label: 'Select',
            ),
          ],
          currentIndex: _selectedIndex,
          // selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 100,
              ),
              Text("Select Wifi printer", style: TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.6))),
              const SizedBox(
                height: 10,
              ),
              Text("Select Bluetooth printer", style: TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.6))),
              const SizedBox(
                height: 10,
              ),
              Text("Select image to print", style: TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.6))),
              const SizedBox(
                height: 50,
              ),
              Text("Grant ALL permissions or the app will crash", style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.6))),
              Expanded(
                child: ListView(
                    shrinkWrap: true,
                    children: _permissionList
                        .where((permission) {
                          if (Platform.isIOS) {
                            return permission != Permission.unknown &&
                                permission != Permission.sms &&
                                permission != Permission.storage &&
                                permission != Permission.ignoreBatteryOptimizations &&
                                permission != Permission.accessMediaLocation &&
                                permission != Permission.activityRecognition &&
                                permission != Permission.manageExternalStorage &&
                                permission != Permission.systemAlertWindow &&
                                permission != Permission.requestInstallPackages &&
                                permission != Permission.accessNotificationPolicy &&
                                permission != Permission.bluetoothScan &&
                                permission != Permission.bluetoothAdvertise &&
                                permission != Permission.bluetoothConnect;
                          } else {
                            return permission != Permission.unknown &&
                                permission != Permission.mediaLibrary &&
                                permission != Permission.photos &&
                                permission != Permission.photosAddOnly &&
                                permission != Permission.reminders &&
                                permission != Permission.appTrackingTransparency &&
                                permission != Permission.criticalAlerts;
                          }
                        })
                        .map((permission) => PermissionWidget(permission))
                        .toList()),
              ),
            ],
          ),

          // child: PermissionHandlerWidget(),
          //     child: Column(
          //   children: [
          //     Text("Select Wifi printer", style: TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.6))),
          //     const SizedBox(
          //       height: 10,
          //     ),
          //     Text("or", style: TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.6))),
          //     const SizedBox(
          //       height: 10,
          //     ),
          //     Text("Select Bluetooth printer", style: TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.6))),
          //     const SizedBox(
          //       height: 100,
          //     ),
          //     Text("Select image to print", style: TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.6))),
          //   ],
          // )
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi),
            label: 'List Printers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth),
            label: 'List Printers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Select',
          ),
        ],
        currentIndex: _selectedIndex,
        // selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
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
      Navigation().openPrintImage(context);
    }
  }

  Future<void> loadPage() async {
    try {
      if (Platform.isAndroid) {
        int index = Permission.values.indexWhere((f) => f.value == Permission.bluetoothScan.value);
        Permission bluetoothScan = Permission.values.elementAt(index);
        index = Permission.values.indexWhere((f) => f.value == Permission.bluetoothConnect.value);
        Permission bluetoothConnect = Permission.values.elementAt(index);
        index = Permission.values.indexWhere((f) => f.value == Permission.storage.value);
        Permission storage = Permission.values.elementAt(index);
        _permissionList = <Permission>[bluetoothScan, bluetoothConnect, storage];
        debugPrint("Home: Permission: _permissionList.length: ${_permissionList.length}");
      }
    } catch (e) {
      debugPrint("Home: loadPage: ERROR $e");
    }
  }
}
