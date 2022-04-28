import 'dart:async';
import 'dart:io';

import 'package:another_brother/printer_info.dart';
import 'package:another_brother/type_b_printer.dart';
import 'package:brotherquickstart/util/navigation.dart';
import 'package:flutter/material.dart';

class BrotherBluetoothPrinter extends StatefulWidget {
  const BrotherBluetoothPrinter({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<BrotherBluetoothPrinter> createState() => _BrotherBluetoothPrinterState();

  static BluetoothPrinter? bluetoothPrinter;
  static final PrinterInfo _printInfo = PrinterInfo();

  static Future<void> print(List<File> files) async {
    debugPrint("BrotherBluetoothPrinter: static void print ${files.length}");
    if (bluetoothPrinter != null) {
      final Printer _printer = Printer();
      String? lookFor = bluetoothPrinter?.modelName;
      if (lookFor == null) {
        return;
      }
      List<Model> models = Model.getValues();
      for (var model in models) {
        if (lookFor.contains(model.getName())) {
          debugPrint("BrotherWifiPrinter: print: FOUND IT: static void print ${model.getName()}");
          await _printer.setPrinterInfo(_printInfo);
          _printInfo.printerModel = model;
          break;
        }
      }
      _printInfo.isAutoCut = true;
      _printInfo.macAddress = bluetoothPrinter!.macAddress;
      _printInfo.port = Port.BLUETOOTH;
      _printInfo.numberOfCopies = 1;

      int x = 0;
      PrinterStatus p = PrinterStatus();
      for (var file in files) {
        //first time to print with device.
        //forces error so it can go to "figure it out" logic below

        if (_printInfo.labelNameIndex == -1) {
          _printer.setPrinterInfo(_printInfo);
          p = await _printer.printFile(file.path);
          if (p.errorCode.getName().compareTo("ERROR_WRONG_LABEL") == 0) {
            // go to "figure it out" logic below
          } else if (p.errorCode.getName().compareTo("ERROR_NONE") != 0) {
            throw Exception(p.errorCode.getName());
          }
        }
        //reuse the previous known good printer and label
        if (p.errorCode.getName().compareTo("ERROR_NONE") == 0) {
          _printer.setPrinterInfo(_printInfo);
          p = await _printer.printFile(file.path);
          if (p.errorCode.getName().compareTo("ERROR_NONE") != 0) {
            throw Exception(p.errorCode.getName());
          }
        }

        // figure it out logic
        while (p.errorCode.getName().compareTo("ERROR_NONE") != 0 && x < 100) {
          x++;
          _printInfo.labelNameIndex = x;
          _printer.setPrinterInfo(_printInfo);
          p = await _printer.printFile(file.path);
          if (p.errorCode.getName().compareTo("ERROR_NONE") == 0) {
            //this info is cached and will remember until the app is closed so....
            //persist this so the next time you launch the app it, will remember the settings
            debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
            debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
            debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
            debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
            debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
            debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
            debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
            //found the correct label
            break;
          } else if (p.errorCode.getName().compareTo("ERROR_WRONG_LABEL") == 0) {
            debugPrint("BrotherBluetoothPrinter: print: PrinterStatus try again: ${_printInfo.labelNameIndex} ${p.errorCode.getName()}");
            //keep trying
          } else {
            debugPrint("BrotherBluetoothPrinter: print: PrinterStatus ERROR: ${_printInfo.labelNameIndex} ${p.errorCode.getName()}");
            throw Exception(p.errorCode.getName());
          }
        }
      }
    }
    debugPrint("BrotherBluetoothPrinter: print: PrinterStatus __printInfo: DONE");
  }
}

class _BrotherBluetoothPrinterState extends State<BrotherBluetoothPrinter> {
  final Printer _printer = Printer();
  List<BluetoothPrinter> _bluetoothPrinters = List.empty(growable: true);
  bool isLoading = true;

  int _selectedIndex = 1;

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
    if (_bluetoothPrinters.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: buildDrawer(),
        body: const SafeArea(
          child: Center(
            child: Text("No bluetooth printers found"),
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
          itemCount: _bluetoothPrinters.length,
          itemBuilder: (BuildContext context, int index) {
            BluetoothPrinter oBluetoothPrinter = _bluetoothPrinters[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              shadowColor: Colors.black,
              // elevation: 11,
              borderOnForeground: false,
              color: Colors.white70,
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.print)),
                    title: Text(oBluetoothPrinter.modelName),
                    subtitle: Text("Address: ${oBluetoothPrinter.macAddress}"),
                    onTap: () {
                      selectPrinter(oBluetoothPrinter);
                    },
                    trailing: buildTrailingIcon(oBluetoothPrinter),
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
    debugPrint("BrotherBluetoothPrinter: loadPage");
    setState(() {
      _bluetoothPrinters = List.empty(growable: true);
      isLoading = true;
    });

    _bluetoothPrinters = await _printer.getBluetoothPrinters([
      TbModel.TD_4650TNWB.getName(),
      TbModel.TD_4650TNWB.getName(),
      TbModel.TD_4650TNWBR.getName(),
      TbModel.TD_4750TNWBR.getName(),
      TbModel.RJ_2035B.getName(),
      TbModel.RJ_2055WB.getName(),
      TbModel.RJ_3035B.getName(),
      TbModel.RJ_3055WB.getName(),
      TbModel.TJ_4420TN.getName(),
      TbModel.TJ_4520TN.getName(),
      TbModel.TJ_4620TN.getName(),
      TbModel.TJ_4422TN.getName(),
      TbModel.TJ_4522TN.getName(),
      Model.MW_140BT.getName(),
      Model.MW_145BT.getName(),
      Model.MW_260.getName(),
      Model.PJ_522.getName(),
      Model.PJ_523.getName(),
      Model.PJ_520.getName(),
      Model.PJ_560.getName(),
      Model.PJ_562.getName(),
      Model.PJ_563.getName(),
      Model.PJ_622.getName(),
      Model.PJ_623.getName(),
      Model.PJ_662.getName(),
      Model.PJ_663.getName(),
      Model.RJ_4030.getName(),
      Model.RJ_4040.getName(),
      Model.RJ_3150.getName(),
      Model.RJ_3050.getName(),
      Model.QL_580N.getName(),
      Model.QL_710W.getName(),
      Model.QL_720NW.getName(),
      Model.TD_2020.getName(),
      Model.TD_2120N.getName(),
      Model.TD_2130N.getName(),
      Model.PT_E550W.getName(),
      Model.PT_P750W.getName(),
      Model.TD_4100N.getName(),
      Model.TD_4000.getName(),
      Model.PJ_762.getName(),
      Model.PJ_763.getName(),
      Model.PJ_773.getName(),
      Model.PJ_722.getName(),
      Model.PJ_723.getName(),
      Model.PJ_763MFi.getName(),
      Model.MW_145MFi.getName(),
      Model.MW_260MFi.getName(),
      Model.PT_P300BT.getName(),
      Model.PT_E850TKW.getName(),
      Model.PT_D800W.getName(),
      Model.PT_P900W.getName(),
      Model.PT_P950NW.getName(),
      Model.RJ_4030Ai.getName(),
      Model.PT_E800W.getName(),
      Model.RJ_2030.getName(),
      Model.RJ_2050.getName(),
      Model.RJ_2140.getName(),
      Model.RJ_2150.getName(),
      Model.RJ_3050Ai.getName(),
      Model.RJ_3150Ai.getName(),
      Model.QL_800.getName(),
      Model.QL_810W.getName(),
      Model.QL_820NWB.getName(),
      Model.QL_1100.getName(),
      Model.QL_1110NWB.getName(),
      Model.QL_1115NWB.getName(),
      Model.PT_P710BT.getName(),
      Model.PT_E500.getName(),
      Model.RJ_4230B.getName(),
      Model.RJ_4250WB.getName(),
      Model.TD_4410D.getName(),
      Model.TD_4420DN.getName(),
      Model.TD_4510D.getName(),
      Model.TD_4520DN.getName(),
      Model.TD_4550DNWB.getName(),
      Model.MW_170.getName(),
      Model.MW_270.getName(),
      Model.PT_P715eBT.getName(),
      Model.PT_P910BT.getName(),
    ]);
    setState(() {
      _bluetoothPrinters;
      isLoading = false;
    });
  }

  void selectPrinter(BluetoothPrinter oBluetoothPrinter) {
    debugPrint("BrotherBluetoothPrinter: selectPrinter: NetPrinter: $oBluetoothPrinter");
    BrotherBluetoothPrinter.bluetoothPrinter = oBluetoothPrinter;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
            'Bluetooth Printer is now active',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amberAccent),
    );
    Navigation().goHome(context);
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

  Icon buildTrailingIcon(BluetoothPrinter oBluetoothPrinter) {
    if (BrotherBluetoothPrinter.bluetoothPrinter == null) {
      return const Icon(Icons.no_cell_outlined);
    }
    if (oBluetoothPrinter.macAddress.compareTo(BrotherBluetoothPrinter.bluetoothPrinter!.macAddress) == 0) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.no_cell_outlined);
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
