import 'package:brotherquickstart/app_permissions_page.dart';
// ignore: unused_import
import 'package:brotherquickstart/brother/brother_bluetooth_ble_printer.dart';
import 'package:brotherquickstart/brother/brother_bluetooth_printer.dart';
import 'package:brotherquickstart/brother/brother_wifi_printer.dart';
import 'package:brotherquickstart/brother/brother_wifi_scanner.dart';
import 'package:brotherquickstart/home.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

class Navigation {
  void openBrotherBluetoothPrinter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BrotherBluetoothPrinter(title: 'Brother Bluetooth Printer'),
      ),
    );
  }

  // void openBrotherBluetoothBlePrinter(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const BrotherBluetoothBlePrinter(title: 'Brother Bluetooth BLE Printer'),
  //     ),
  //   );
  // }

  void openBrotherBrotherWifiScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BrotherWifiScanner(title: 'Brother Wifi Scanner'),
      ),
    );
  }

  void openBrotherWifiPrinter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BrotherWifiPrinter(title: 'Brother Wifi Printer'),
      ),
    );
  }

  // void openPrintImage(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const PrintImage(title: 'Print Image'),
  //     ),
  //   );
  // }

  void goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => const Home(
                title: "4Site Hacks",
              )),
      (Route<dynamic> route) => false,
    );
  }

  void openAppPermissions(BuildContext context, List<Permission> permissionList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppPermissions(title: 'App Permissions', permissionList: permissionList),
      ),
    );
  }
}
