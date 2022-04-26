import 'package:brotherquickstart/util/navigation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:another_brother/printer_info.dart';
import "dart:ui" as ui;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class BrotherWifiPrinter extends StatefulWidget {
  final String title;
  const BrotherWifiPrinter({Key? key, required this.title}) : super(key: key);
  @override
  State<BrotherWifiPrinter> createState() => _BrotherWifiPrinterState();

  static NetPrinter? netPrinter;
  static final PrinterInfo _printInfo = PrinterInfo();

  static Future<void> print(File file) async {
    debugPrint("BrotherWifiPrinter: static void print ${file.path}");
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
      int x = 0;
      PrinterStatus p = PrinterStatus();
      //first time to print with device.
      //forces error so it can go to "figure it out" logic below
      if (_printInfo.labelNameIndex == -1) {
        p = await _printer.printFile(file.path);
        if (p.errorCode.getName().compareTo("ERROR_WRONG_LABEL") == 0) {
          // go to "figure it out" logic below
          debugPrint("BrotherWifiPrinter: print: first time: go to 'figure it out' logic below: ${_printInfo.labelNameIndex} ");
        }
        else if (p.errorCode.getName().compareTo("ERROR_NONE") != 0) {
          debugPrint("BrotherWifiPrinter: print: first time: reuse: ${_printInfo.labelNameIndex} ${p.errorCode.getName()}");
          throw Exception(p.errorCode.getName());
        }
      }
      // reuse the last good print settings
      if (p.errorCode.getName().compareTo("ERROR_NONE") == 0 && _printInfo.labelNameIndex != -1) {
        debugPrint("BrotherWifiPrinter: print: Life is good: reuse: ${_printInfo.labelNameIndex} ${p.errorCode.getName()}");
        p = await _printer.printFile(file.path);
        if (p.errorCode.getName().compareTo("ERROR_NONE") != 0) {
          debugPrint("BrotherWifiPrinter: print: Life is good: ERROR: ${_printInfo.labelNameIndex} ${p.errorCode.getName()}");
          throw Exception(p.errorCode.getName());
        }
      }

      //figure it out" logic
      while (p.errorCode.getName().compareTo("ERROR_NONE") != 0 && x < 100) {
        x++;
        _printInfo.labelNameIndex = x;
        _printer.setPrinterInfo(_printInfo);
        p = await _printer.printFile(file.path);
        if (p.errorCode.getName().compareTo("ERROR_NONE") == 0) {
          //found the correct label
          //this info is cached and will remember until the app is closed so....
          //persist this so the next time you launch the app it, will remember the settings
          debugPrint("BrotherWifiPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
          debugPrint("BrotherWifiPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
          debugPrint("BrotherWifiPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
          debugPrint("BrotherWifiPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
          debugPrint("BrotherWifiPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
          debugPrint("BrotherWifiPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
          debugPrint("BrotherWifiPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
          break;
        }
        else if (p.errorCode.getName().compareTo("ERROR_WRONG_LABEL") == 0) {
          debugPrint("BrotherWifiPrinter: print: PrinterStatus try again: ${_printInfo.labelNameIndex} ${p.errorCode.getName()}");
        }
        else {
          debugPrint("BrotherWifiPrinter: print: PrinterStatus ERROR: ${_printInfo.labelNameIndex} ${p.errorCode.getName()}");
          throw Exception(p.errorCode.getName());
        }
      }
      return;
    }
    debugPrint("BrotherWifiPrinter: static void print ERROR");
  }
}

class _BrotherWifiPrinterState extends State<BrotherWifiPrinter> {
  List<NetPrinter> _netPrinterList = List.empty(growable: true);
  bool isLoading = true;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    loadPage();
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return Container();
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
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
        body: const SafeArea(
          child: Center(
            child: Text("No Wifi printers found"),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
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

  Icon buildTrailingIcon(NetPrinter oNetPrinter) {
    if (BrotherWifiPrinter.netPrinter == null) {
      return const Icon(Icons.no_cell_outlined);
    }
    if (oNetPrinter.ipAddress.compareTo(BrotherWifiPrinter.netPrinter!.ipAddress) == 0) {
      return const Icon(Icons.check);
    }
    return const Icon(Icons.no_cell_outlined);
  }

  Future<void> loadPage() async {
    debugPrint("BrotherWifiPrinter: loadPage");
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
      loadPage();
    }
    if (_selectedIndex == 1) {
      Navigation().openBrotherBluetoothPrinter(context);
    }
    if (_selectedIndex == 2) {
      Navigation().openPrintImage(context);
    }
  }
}
