import 'package:flutter/material.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';

import '../../service/exceptions/auth_exception.dart';
import '../../service/exceptions/database_exception.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return null;
    }
//    if (error is ValidationException) {
//      return error.message;
//    }

    if (error is DatabaseException) {
      return error.message;
    }
    if (error is AuthorizationException) {
      return error.message;
    }
    if (error is NASFileException) {
      return error.message;
    }

    return 'Unknown error';
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Text(ErrorHandler.getErrorMessage(error)),
            Spacer(),
            Icon(Icons.error_outline, color: Colors.yellow)
          ],
        ),
      ),
    );
  }

  static void showErrorDialog(BuildContext context, dynamic error, [bool dismissView = false]) {
    if (dismissView) {
      Navigator.of(context).pop();
    }
    showDialog<AlertDialog>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline,
                color: Colors.yellow,
              ),
              Text(ErrorHandler.getErrorMessage(error)),
            ],
          ),
        );
      },
    );
  }
}
