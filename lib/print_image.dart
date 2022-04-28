// import 'dart:io';
//
// import 'package:brotherquickstart/brother/brother_bluetooth_printer.dart';
// import 'package:brotherquickstart/brother/brother_wifi_printer.dart';
// import 'package:brotherquickstart/util/navigation.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
//
// class PrintImage extends StatefulWidget {
//   final String title;
//   const PrintImage({Key? key, required this.title}) : super(key: key);
//
//   @override
//   State<PrintImage> createState() => _PrintImageState();
// }
//
// class _PrintImageState extends State<PrintImage> {
//   int _selectedIndex = 2;
//   bool isPrinting = false;
//
//   File? _file;
//   @override
//   void initState() {
//     super.initState();
//     loadPage();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (isPrinting) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//         ),
//         body: SafeArea(
//           child: Center(
//               child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const LinearProgressIndicator(),
//               const SizedBox(
//                 height: 10,
//               ),
//               Text("Calculating correct printing label", style: TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.6))),
//             ],
//           )),
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
//     if (_file != null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//         ),
//         body: SafeArea(
//           child: Center(
//             child: Column(
//               children: [
//                 const SizedBox(
//                   height: 15,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     TextButton.icon(
//                       style: TextButton.styleFrom(
//                         textStyle: const TextStyle(color: Colors.blue),
//                         backgroundColor: Colors.black12,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24.0),
//                         ),
//                       ),
//                       onPressed: () => {printBrotherWifiPrinter()},
//                       icon: const Icon(
//                         Icons.wifi,
//                       ),
//                       label: const Text(
//                         'Wifi print',
//                       ),
//                     ),
//                     TextButton.icon(
//                       style: TextButton.styleFrom(
//                         textStyle: const TextStyle(color: Colors.blue),
//                         backgroundColor: Colors.black12,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24.0),
//                         ),
//                       ),
//                       onPressed: () => {printBrotherBluetoothPrinter()},
//                       icon: const Icon(
//                         Icons.bluetooth,
//                       ),
//                       label: const Text(
//                         'Bluetooth print',
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 22,
//                 ),
//                 Image.file(_file!),
//               ],
//             ),
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
//       body: const SafeArea(
//         child: Center(
//           child: Text("Select an image"),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.wifi),
//             label: 'Printers',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.bluetooth),
//             label: 'Printers',
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


//
//   Future<void> loadPage() async {
//     debugPrint("PrintImage: loadPage");
//     FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
//     if (result == null) {
//       return;
//     }
//     PlatformFile? _platformFile = result.files.first;
//     String? s = _platformFile.path;
//     _file = File(s!);
//     setState(() {});
//   }
//
//   Future<void> printBrotherWifiPrinter() async {
//     debugPrint("PrintImage: printBrotherWifiPrinter: $_file");
//     if (_file == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text(
//               'Select image first',
//               style: TextStyle(color: Colors.black),
//             ),
//             backgroundColor: Colors.amberAccent),
//       );
//       return;
//     }
//     if (BrotherWifiPrinter.netPrinter == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text(
//               'Wifi printer has not been selected',
//               style: TextStyle(color: Colors.black),
//             ),
//             backgroundColor: Colors.amberAccent),
//       );
//       return;
//     }
//     setState(() {
//       isPrinting = true;
//     });
//     // _file = await ImageUtil().rotate(_file!.path, 90);
//     //here is the print statement
//     await BrotherWifiPrinter.print(_file!);
//     setState(() {
//       isPrinting = false;
//     });
//   }
//
//   Future<void> printBrotherBluetoothPrinter() async {
//     debugPrint("PrintImage: printBrotherBluetoothPrinter: $_file");
//     if (_file == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text(
//               'Select image first',
//               style: TextStyle(color: Colors.black),
//             ),
//             backgroundColor: Colors.amberAccent),
//       );
//       return;
//     }
//     if (BrotherBluetoothPrinter.bluetoothPrinter == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text(
//               'Bluetooth printer has not been selected',
//               style: TextStyle(color: Colors.black),
//             ),
//             backgroundColor: Colors.amberAccent),
//       );
//       return;
//     }
//     setState(() {
//       isPrinting = true;
//     });
//     // _file = await ImageUtil().rotate(_file!.path, 90);
//     //here is the print statement
//     await BrotherBluetoothPrinter.print(_file!).onError((error, stackTrace) {
//       debugPrint("PrintImage: printBrotherBluetoothPrinter: onError:  $error stackTrace: $stackTrace");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(
//               error.toString(),
//               style: const TextStyle(color: Colors.black),
//             ),
//             backgroundColor: Colors.amberAccent),
//       );
//     }).catchError((catchError) {
//       debugPrint("PrintImage: printBrotherBluetoothPrinter: catchError:  $catchError");
//     });
//     setState(() {
//       isPrinting = false;
//     });
//   }
// }
