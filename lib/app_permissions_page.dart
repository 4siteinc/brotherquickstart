import 'dart:async';
import 'dart:io';

import 'package:brotherquickstart/util/navigation.dart';
import 'package:brotherquickstart/util/permission_util.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissions extends StatefulWidget {
  final String title;
  final List<Permission> permissionList;

  const AppPermissions({Key? key, required this.title, required this.permissionList}) : super(key: key);

  @override
  State<AppPermissions> createState() => _AppPermissionsState();
}

class _AppPermissionsState extends State<AppPermissions> {
  int _selectedIndex = 0;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => loadPage());
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.permissionList.isEmpty && Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: buildDrawer(),
        body: const SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 55,
              ),
              Text("Grant ALL permissions or the app will crash", style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.6))),
              Expanded(
                child: ListView(
                    shrinkWrap: true,
                    children: widget.permissionList
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
      bottomNavigationBar: buildBottomNavigationBar(),
    );
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
          icon: Icon(Icons.image),
          label: 'Select',
        ),
      ],
      currentIndex: _selectedIndex,
      // selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
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
      Navigation().openBrotherBrotherWifiScanner(context);
    }
    if (_selectedIndex == 3) {
      Navigation().goHome(context);
    }
  }

  Future<void> loadPage() async {
    try {
      bool doGoHome = true;
      for (var element in widget.permissionList) {
        if (!await element.isGranted) {
          doGoHome = false;
        }
      }
      if (doGoHome) {
        timer?.cancel();
        Navigation().goHome(context);
      }
    } catch (e) {
      debugPrint("Home: loadPage: ERROR $e");
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
              // TextButton.icon(
              //   label: const Text("Campaign"),
              //   onPressed: () {
              //     Navigator.pop(context);
              //     openCampaignScreen();
              //   },
              //   icon: Image.asset('assets/votex24.png', color: Colors.blue),
              // ),
              // TextButton.icon(
              //   label: const Text("Results"),
              //   onPressed: () {
              //     Navigator.pop(context);
              //     openVotingResultsScreen();
              //   },
              //   icon: Image.asset('assets/view-galleryx24.png', color: Colors.blue),
              // ),
            ],
          ),
        ],
      ),
    );
  }

}
