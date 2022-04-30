import 'dart:async';
import 'dart:io';

import 'package:another_brother/printer_info.dart';
import 'package:brotherquickstart/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class BrotherWifiPrinter extends StatefulWidget {
  final String title;

  const BrotherWifiPrinter({Key? key, required this.title}) : super(key: key);

  @override
  State<BrotherWifiPrinter> createState() => _BrotherWifiPrinterState();

  static NetPrinter? netPrinter;
  static final PrinterInfo _printInfo = PrinterInfo();
  static final List<int> _values = List.empty(growable: true);

  static Future<void> print(final List<File> files, Function(PrinterStatus printerStatus, PrinterInfo printInfo) eventListenerPrintStatus) async {

    debugPrint("BrotherWifiPrinter: static void print ${files.length}");

    if (netPrinter != null) {
      final Printer _printer = Printer();
      debugPrint("BrotherWifiPrinter: static void print ${netPrinter?.modelName}");
      String? lookFor = netPrinter?.modelName;
      if (lookFor == null) {
        return;
      }
      List<Model> models = Model.getValues();
      for (var model in models) {
        if (lookFor.contains(model.getName())) {
          debugPrint("BrotherWifiPrinter: FOUND IT: static void print ${model.getName()}");
          await _printer.setPrinterInfo(_printInfo);
          _printInfo.printerModel = model;
          break;
        }
      }

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      _printInfo.workPath = tempPath;
      _printInfo.printMode = PrintMode.FIT_TO_PAGE;
      _printInfo.isAutoCut = true;
      _printInfo.port = Port.NET;
      _printInfo.paperSize = PaperSize.CUSTOM;
      _printInfo.ipAddress = netPrinter!.ipAddress;
      _printInfo.numberOfCopies = 1;
      _printInfo.isAutoCut = true;
      _printInfo.isCutAtEnd = true;
      _printInfo.isHalfCut = false;
      _printInfo.isSpecialTape = false;
      PrinterStatus printerStatus = PrinterStatus();
      //first time to print with device.
      //forces error so it can go to "figure it out" logic below

      for (var file in files) {

        try{
          //reuse the previous known good printer and label
          printerStatus = await _printer.printFile(file.path);
          if (printerStatus.errorCode.getName().compareTo(ErrorCode.ERROR_NONE.getName()) == 0) {
            eventListenerPrintStatus(printerStatus, _printInfo);
            continue;
          }
          eventListenerPrintStatus(printerStatus, _printInfo);
          throw Exception(printerStatus.errorCode.getName());
        }
        catch(e){
          //forces error so it can go to "figure it out" logic below
          await loadLabelNameIndexes(_printInfo.printerModel);
          _printInfo.isAutoCut = true;
          _printInfo.numberOfCopies = 1;

          for (int value in _values) {
            debugPrint("BrotherBluetoothPrinter: print: trying value.getPaperId: $value ");
            _printInfo.labelNameIndex = value;
            // _printInfo.paperSize = value;
            _printer.setPrinterInfo(_printInfo);
            printerStatus = await _printer.printFile(file.path);
            eventListenerPrintStatus(printerStatus, _printInfo);
            if (printerStatus.errorCode.getName().compareTo("ERROR_NONE") == 0) {
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
            } else if (printerStatus.errorCode.getName().compareTo("ERROR_WRONG_LABEL") == 0) {
              debugPrint("BrotherBluetoothPrinter: print: PrinterStatus try again: ${_printInfo.labelNameIndex} ${printerStatus.errorCode.getName()}");
              //keep trying
            } else {
              debugPrint("BrotherBluetoothPrinter: print: PrinterStatus ERROR: ${_printInfo.labelNameIndex} ${printerStatus.errorCode.getName()}");
              throw Exception(printerStatus.errorCode.getName());
            }
          }
        }

      }
      return;
    }
    debugPrint("BrotherWifiPrinter: static void print ERROR");
  }


  static Future<void>  loadLabelNameIndexes(Model printerModel) async {
    for (int x=0;x<100;x++) {
      try{
        if(printerModel.getLabelID(x) != 255){
          debugPrint("BrotherWifiPrinter: loadLabelNameIndexes: printerModel.getLabelID: ${printerModel.getLabelID(x)} ");
          _values.add(printerModel.getLabelID(x));
        }
      }
      catch(e){
        //this is OK
      }
    }
  }

}


class _BrotherWifiPrinterState extends State<BrotherWifiPrinter> {
  List<NetPrinter> _netPrinterList = List.empty(growable: true);
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
    if (_netPrinterList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: buildDrawer(),
        body: const SafeArea(
          child: Center(
            child: Text("No Wifi printers found"),
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
          itemCount: _netPrinterList.length,
          itemBuilder: (BuildContext context, int index) {
            NetPrinter oNetPrinter = _netPrinterList[index];
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
                    title: Text(oNetPrinter.modelName),
                    subtitle: Text("Address: ${oNetPrinter.ipAddress}"),
                    onTap: () {
                      selectPrinter(oNetPrinter);
                    },
                    trailing: buildTrailingIcon(oNetPrinter),
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

  Icon buildTrailingIcon(NetPrinter oNetPrinter) {
    if (BrotherWifiPrinter.netPrinter == null) {
      return const Icon(Icons.no_cell_outlined);
    }
    if (oNetPrinter.ipAddress.compareTo(BrotherWifiPrinter.netPrinter!.ipAddress) == 0) {
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
    debugPrint("BrotherWifiPrinter: loadPage");
    setState(() {
       _netPrinterList = List.empty(growable: true);
      isLoading = true;
    });

    final Printer _printer = Printer();
    _netPrinterList = await _printer.getNetPrinters([
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
      _netPrinterList;
      isLoading = false;
    });
    debugPrint("BrotherWifiPrinter: loadPage: _netPrinterList.length: ${_netPrinterList.length}");
  }

  void selectPrinter(NetPrinter oNetPrinter) {
    debugPrint("BrotherWifiPrinter: selectPrinter: NetPrinter: $oNetPrinter");
    BrotherWifiPrinter.netPrinter = oNetPrinter;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
            'Wifi Printer is now active',
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
