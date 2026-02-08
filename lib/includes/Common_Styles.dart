import 'package:flutter/material.dart';

class CommonStyles {
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    minimumSize: const Size.fromHeight(40),
  );
}
