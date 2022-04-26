
import 'package:brotherquickstart/brother/brother_bluetooth_printer.dart';
import 'package:brotherquickstart/brother/brother_wifi_printer.dart';
import 'package:brotherquickstart/home.dart';
import 'package:brotherquickstart/print_image.dart';
import 'package:flutter/material.dart';

class Navigation {
  void openBrotherBluetoothPrinter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BrotherBluetoothPrinter(title: 'Brother Bluetooth Printer'),
      ),
    );
  }

  void openBrotherBrotherWifiScanner(BuildContext context) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => const BrotherWifiScanner(title: 'Brother Wifi Scanner'),
    //   ),
    // );
  }
  void openBrotherWifiPrinter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BrotherWifiPrinter(title: 'Brother Wifi Printer'),
      ),
    );
  }

  void openPrintImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrintImage(title: 'Print Image'),
      ),
    );
  }

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
}
