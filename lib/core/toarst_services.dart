import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ToastService {
  static void show(String message, {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: message,
      gravity: gravity,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }
}