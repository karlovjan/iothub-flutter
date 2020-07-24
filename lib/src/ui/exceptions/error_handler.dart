import 'package:flutter/material.dart';
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

    throw (error);
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(
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

  static void showErrorDialog(BuildContext context, dynamic error) {
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
