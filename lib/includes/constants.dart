import 'package:flutter/material.dart';

const String appname = "Daily Drop";

ValueNotifier<int> selectedPageNotifier = ValueNotifier<int>(0);

class CommonStyles {
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    minimumSize: const Size.fromHeight(40),
  );
}
