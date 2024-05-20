import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:another_flushbar/flushbar.dart';


import 'icons.dart';

class ErrorUtils {
  /// Show red snack-bar on top of the app.
  /// with [exception] message.
  static Future<dynamic> showGeneralError(
      BuildContext context, dynamic exception,
      {required Duration duration}) async {
    String message;
    if(exception is String){
      message = exception.toString();
    }else{
      message = exception.message;
    }

    Flushbar flushBar = Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.red,
      borderRadius: BorderRadius.circular(5.0),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      messageText: Row(
        children: <Widget>[
          GestureDetector(
            child: Icon(Icons.close, color: Colors.white),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: Colors.white))),
        ],
      ),
      margin: EdgeInsets.fromLTRB(32, 12, 32, 12),
      duration: duration ?? Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 300),
    );
    return flushBar.show(context);
  }

  /// Show green snack-bar on top of the app.
  /// with [message].
  static Future<dynamic> showSuccessMessage(
      BuildContext context, String message) {
    Flushbar flushBar = Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Color.fromARGB(255, 94, 203, 117),
      borderRadius: BorderRadius.circular(5.0),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      messageText: Row(
        children: <Widget>[
          SvgPicture.asset(kCheckboxIcon, height: 26, width: 26),
          SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(color: Color.fromARGB(255, 18, 20, 20))),
          ),
        ],
      ),
      margin: EdgeInsets.fromLTRB(32, 12, 32, 12),
      duration: Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 300),
    );

    return flushBar.show(context);
  }
}

/// See also:
///
/// - [ErrorUtils].
extension ErrorUtilsContext on BuildContext {
  Future<dynamic> showGeneralError(exception, {required Duration duration}) {
    return ErrorUtils.showGeneralError(this, exception, duration: duration);
  }

  Future<dynamic> showSuccessMessage(String message) {
    return ErrorUtils.showSuccessMessage(this, message);
  }
}
