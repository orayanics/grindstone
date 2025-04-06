import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grindstone/core/config/colors.dart';

class FailToast {
  static void show(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        webBgColor: webFail,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16);
  }
}

class SuccessToast {
  static void show(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        webBgColor: webSuccess,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16);
  }
}
