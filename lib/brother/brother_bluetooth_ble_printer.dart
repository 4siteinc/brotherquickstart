// import 'dart:async';
// import 'dart:io';
//
// import 'package:another_brother/printer_info.dart';
// import 'package:another_brother/type_b_printer.dart';
// import 'package:brotherquickstart/util/navigation.dart';
// import 'package:flutter/material.dart';
//
// class BrotherBluetoothBlePrinter extends StatefulWidget {
//   const BrotherBluetoothBlePrinter({Key? key, required this.title}) : super(key: key);
//   final String title;
//
//   @override
//   State<BrotherBluetoothBlePrinter> createState() => _BrotherBluetoothBlePrinterState();
//
//   static BluetoothPrinter? bluetoothPrinter;
//   static final PrinterInfo _printInfo = PrinterInfo();
//
//   static Future<void> print(List<File> files) async {
//     debugPrint("BrotherBluetoothPrinter: static void print ${files.length}");
//     if (bluetoothPrinter != null) {
//       final Printer _printer = Printer();
//       _printInfo.isAutoCut = true;
//       String? lookFor = bluetoothPrinter?.modelName;
//       if (lookFor == null) {
//         return;
//       }
//       List<Model> models = Model.getValues();
//       for (var model in models) {
//         if (lookFor.contains(model.getName())) {
//           debugPrint("BrotherWifiPrinter: print: FOUND IT: static void print ${model.getName()}");
//           await _printer.setPrinterInfo(_printInfo);
//           _printInfo.printerModel = model;
//           break;
//         }
//       }
//       _printInfo.macAddress = bluetoothPrinter!.macAddress;
//       _printInfo.port = Port.BLUETOOTH;
//       _printInfo.numberOfCopies = 1;
//
//       int x = 0;
//       PrinterStatus p = PrinterStatus();
//       for (var file in files) {
//         //first time to print with device.
//         //forces error so it can go to "figure it out" logic below
//
//         if (_printInfo.labelNameIndex == -1) {
//           p = await _printer.printFile(file.path);
//           if (p.errorCode.getName().compareTo("ERROR_WRONG_LABEL") == 0) {
//             // go to "figure it out" logic below
//           } else if (p.errorCode.getName().compareTo("ERROR_NONE") != 0) {
//             throw Exception(p.errorCode.getName());
//           }
//         }
//         //reuse the previous known good printer and label
//         if (p.errorCode.getName().compareTo("ERROR_NONE") == 0) {
//           p = await _printer.printFile(file.path);
//           if (p.errorCode.getName().compareTo("ERROR_NONE") != 0) {
//             throw Exception(p.errorCode.getName());
//           }
//         }
//
//         // figure it out logic
//         while (p.errorCode.getName().compareTo("ERROR_NONE") != 0 && x < 100) {
//           x++;
//           _printInfo.labelNameIndex = x;
//           _printer.setPrinterInfo(_printInfo);
//           p = await _printer.printFile(file.path);
//           if (p.errorCode.getName().compareTo("ERROR_NONE") == 0) {
//             //this info is cached and will remember until the app is closed so....
//             //persist this so the next time you launch the app it, will remember the settings
//             debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
//             debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
//             debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
//             debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
//             debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
//             debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
//             debugPrint("BrotherBluetoothPrinter: print: PrinterStatus found the correct label: ${_printInfo.labelNameIndex} ");
//             //found the correct label
//             break;
//           } else if (p.errorCode.getName().compareTo("ERROR_WRONG_LABEL") == 0) {
//             debugPrint("BrotherBluetoothPrinter: print: PrinterStatus try again: ${_printInfo.labelNameIndex} ${p.errorCode.getName()}");
//             //keep trying
//           } else {
//             debugPrint("BrotherBluetoothPrinter: print: PrinterStatus ERROR: ${_printInfo.labelNameIndex} ${p.errorCode.getName()}");
//             throw Exception(p.errorCode.getName());
//           }
//         }
//       }
//     }
//     debugPrint("BrotherBluetoothPrinter: print: PrinterStatus __printInfo: DONE");
//   }
// }
//
// class _BrotherBluetoothBlePrinterState extends State<BrotherBluetoothBlePrinter> {
//   final Printer _printer = Printer();
//   List<BluetoothPrinter> _bluetoothPrinters = List.empty(growable: true);
//   bool isLoading = true;
//
//   int _selectedIndex = 1;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance?.addPostFrameCallback((_) {
//       loadPage();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!mounted) return Container();
//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//         ),
//         body: const SafeArea(
//           child: Center(child: CircularProgressIndicator()),
//         ),
//       );
//     }
//     if (_bluetoothPrinters.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//         ),
//         body: const SafeArea(
//           child: Center(
//             child: Text("No bluetooth printers found"),
//           ),
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           items: const <BottomNavigationBarItem>[
//             BottomNavigationBarItem(
//               icon: Icon(Icons.wifi),
//               label: 'Printers',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.bluetooth),
//               label: 'Printers',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.image),
//               label: 'Select',
//             ),
//           ],
//           currentIndex: _selectedIndex,
//           // selectedItemColor: Colors.amber[800],
//           onTap: _onItemTapped,
//         ),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: SafeArea(
//         child: ListView.builder(
//           shrinkWrap: true,
//           itemCount: _bluetoothPrinters.length,
//           itemBuilder: (BuildContext context, int index) {
//             BluetoothPrinter oBluetoothPrinter = _bluetoothPrinters[index];
//             return Card(
//               clipBehavior: Clip.antiAlias,
//               shadowColor: Colors.black,
//               // elevation: 11,
//               borderOnForeground: false,
//               color: Colors.white70,
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const CircleAvatar(child: Icon(Icons.print)),
//                     title: Text(oBluetoothPrinter.modelName),
//                     subtitle: Text("Address: ${oBluetoothPrinter.macAddress}"),
//                     onTap: () {
//                       selectPrinter(oBluetoothPrinter);
//                     },
//                     trailing: buildTrailingIcon(oBluetoothPrinter),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.wifi),
//             label: 'List Printers',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.bluetooth),
//             label: 'List Printers',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.image),
//             label: 'Select',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         // selectedItemColor: Colors.amber[800],
//         onTap: _onItemTapped,
//       ),
//     );
//   }
//
//   Future<void> loadPage() async {
//     debugPrint("BrotherBluetoothPrinter: loadPage");
//     setState(() {
//       _bluetoothPrinters = List.empty(growable: true);
//       isLoading = true;
//     });
//
//     List<BLEPrinter> blePrinters = await _printer.getBLEPrinters(5000);
//
//     setState(() {
//       _bluetoothPrinters;
//       isLoading = false;
//     });
//   }
//
//   void selectPrinter(BluetoothPrinter oBluetoothPrinter) {
//     debugPrint("BrotherBluetoothPrinter: selectPrinter: NetPrinter: $oBluetoothPrinter");
//     BrotherBluetoothBlePrinter.bluetoothPrinter = oBluetoothPrinter;
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//           content: Text(
//             'Bluetooth Printer is now active',
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Colors.amberAccent),
//     );
//     Navigation().goHome(context);
//   }
//

//
//   Icon buildTrailingIcon(BluetoothPrinter oBluetoothPrinter) {
//     if (BrotherBluetoothBlePrinter.bluetoothPrinter == null) {
//       return const Icon(Icons.no_cell_outlined);
//     }
//     if (oBluetoothPrinter.macAddress.compareTo(BrotherBluetoothBlePrinter.bluetoothPrinter!.macAddress) == 0) {
//       return const Icon(Icons.check);
//     }
//     return const Icon(Icons.no_cell_outlined);
//   }
// }
