import 'dart:io';

import 'package:brotherquickstart/brother/brother_bluetooth_printer.dart';
import 'package:brotherquickstart/brother/brother_wifi_printer.dart';
import 'package:brotherquickstart/util/navigation.dart';
import 'package:file_picker/file_picker.dart';
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

  List<File> files = List.empty(growable: true);

  bool isPrinting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      loadPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isPrinting) {
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
              const LinearProgressIndicator(),
              const SizedBox(
                height: 10,
              ),
              Text("Calculating correct printing label", style: TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.6))),
            ],
          )),
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
      );
    }
    if (files.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(color: Colors.blue),
                    backgroundColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  onPressed: () => {printBrotherWifiPrinter()},
                  icon: const Icon(
                    Icons.wifi,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Print ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 11,
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(color: Colors.blue),
                    backgroundColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  onPressed: () => {printBrotherBluetoothPrinter()},
                  icon: const Icon(
                    Icons.bluetooth,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Print  ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 11,
                ),
              ],
            ),
          ],
        ),
        drawer: buildDrawer(),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const SizedBox(
                    height: 11,
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: files.length,
                    itemBuilder: (BuildContext context, int index) {
                      File file = files[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shadowColor: Colors.black,
                        // elevation: 11,
                        borderOnForeground: false,
                        color: Colors.white70,
                        child: Column(
                          children: [
                            Image.file(file),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
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
      body: const SafeArea(
        child: Center(
          child: Text("Select Images to print"),
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
      selectPictures();
    }
  }

  Future<void> loadPage() async {
    try {
      List<Permission> _permissionList = List.empty(growable: true);
      int index = -99;
      bool doAskForPermission = false;
      if (Platform.isAndroid) {
        index = Permission.values.indexWhere((f) => f.value == Permission.bluetoothScan.value);
        Permission bluetoothScan = Permission.values.elementAt(index);
        if (!await Permission.bluetoothScan.isGranted) {
          doAskForPermission = true;
        }
        index = Permission.values.indexWhere((f) => f.value == Permission.bluetoothConnect.value);
        Permission bluetoothConnect = Permission.values.elementAt(index);
        if (!await Permission.bluetoothConnect.isGranted) {
          doAskForPermission = true;
        }
        index = Permission.values.indexWhere((f) => f.value == Permission.storage.value);
        Permission storage = Permission.values.elementAt(index);
        if (!await Permission.storage.isGranted) {
          doAskForPermission = true;
        }
        debugPrint("Home: Permission: bluetoothScan: ${await Permission.bluetoothScan.isGranted}");
        debugPrint("Home: Permission: bluetoothConnect: ${await Permission.bluetoothConnect.isGranted}");
        debugPrint("Home: Permission: 1storage ${await Permission.storage.isGranted}");

        _permissionList = <Permission>[bluetoothScan, bluetoothConnect, storage];
        debugPrint("Home: Permission: _permissionList.length: ${_permissionList.length}");
      }
      // if (Platform.isIOS) {
      //   index = Permission.values.indexWhere((f) => f.value == Permission.storage.value);
      //   Permission storage = Permission.values.elementAt(index);
      //   if (!await Permission.storage.isGranted) {
      //     doAskForPermission = true;
      //   }
      //
      //   index = Permission.values.indexWhere((f) => f.value == Permission.bluetoothScan.value);
      //   Permission bluetoothScan = Permission.values.elementAt(index);
      //   if (!await Permission.bluetoothScan.isGranted) {
      //     doAskForPermission = true;
      //   }
      //
      //   index = Permission.values.indexWhere((f) => f.value == Permission.bluetoothAdvertise.value);
      //   Permission bluetoothAdvertise = Permission.values.elementAt(index);
      //   if (!await Permission.bluetoothAdvertise.isGranted) {
      //     doAskForPermission = true;
      //   }
      //
      //   index = Permission.values.indexWhere((f) => f.value == Permission.bluetoothConnect.value);
      //   Permission bluetoothConnect = Permission.values.elementAt(index);
      //   if (!await Permission.bluetoothConnect.isGranted) {
      //     doAskForPermission = true;
      //   }
      //   _permissionList = <Permission>[storage, bluetoothScan, bluetoothAdvertise, bluetoothConnect];
      //   debugPrint("Home: Permission: _permissionList.length: ${_permissionList.length}");
      // }
      if (doAskForPermission) {
        Navigation().openAppPermissions(context, _permissionList);
      }
    } catch (e) {
      debugPrint("Home: loadPage: ERROR $e");
    }
  }

  Future<void> printBrotherWifiPrinter() async {
    debugPrint("PrintImage: printBrotherWifiPrinter: files");
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'Select images to print',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.amberAccent),
      );
      return;
    }
    if (BrotherWifiPrinter.netPrinter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'Wifi printer has not been selected',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.amberAccent),
      );
      return;
    }
    setState(() {
      isPrinting = true;
    });
    // _file = await ImageUtil().rotate(_file!.path, 90);
    //here is the print statement
    await BrotherWifiPrinter.print(files).onError((error, stackTrace) => {
    debugPrint("PrintImage: BrotherWifiPrinter: error: $error stackTrace: $stackTrace")
    }).catchError((onError) => {
      debugPrint("PrintImage: BrotherWifiPrinter: onError: $onError ")
    });
    setState(() {
      isPrinting = false;
    });
  }

  Future<void> printBrotherBluetoothPrinter() async {
    debugPrint("PrintImage: printBrotherBluetoothPrinter: ${files.length}");
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'Select image first',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.amberAccent),
      );
      return;
    }
    if (BrotherBluetoothPrinter.bluetoothPrinter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'Bluetooth printer has not been selected',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.amberAccent),
      );
      return;
    }
    setState(() {
      isPrinting = true;
    });
    // _file = await ImageUtil().rotate(_file!.path, 90);
    //here is the print statement
    await BrotherBluetoothPrinter.print(files).onError((error, stackTrace) {
      debugPrint("PrintImage: printBrotherBluetoothPrinter: onError:  $error stackTrace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
              error.toString(),
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.amberAccent),
      );
    }).catchError((catchError) {
      debugPrint("PrintImage: printBrotherBluetoothPrinter: catchError:  $catchError");
    });
    setState(() {
      isPrinting = false;
    });
  }

  Future<void> selectPictures() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
    if (result == null) {
      return;
    }
    for (var file in result.files) {
      String? s = file.path;
      files.add(File(s!));
    }
    setState(() {});
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
