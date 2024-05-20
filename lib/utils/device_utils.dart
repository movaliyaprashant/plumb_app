import 'package:flutter/services.dart';

class DeviceUtils {

  static hideKB() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}