import 'package:flutter/material.dart';
import 'package:iothub/src/service/exceptions/nas_file_sync_exception.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../service/exceptions/auth_exception.dart';
import '../../service/exceptions/database_exception.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return '';
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

    return Error.safeToString(error);
  }

  static Widget getErrorDialog(dynamic error){
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            color: Colors.yellow,
          ),
          Text(ErrorHandler.getErrorMessage(error)),
        ],
      ),
    );
  }

  static Widget getErrorDialogWithBackButton(dynamic error){
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            color: Colors.yellow,
          ),
          Text(ErrorHandler.getErrorMessage(error)),
          ElevatedButton(
            onPressed: () => RM.navigate.back(),
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }

  static void showErrorDialog(dynamic error) {

    //Flutter Way
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       content: Text(errorMessage(error)),
    //     );
    //   },
    // );

    RM.navigate.toDialog(getErrorDialog(error));
  }

  //Display an snackBar with the error message
  static void showSnackBar(dynamic error) {
    if (error == null) {
      return;
    }
    RM.scaffold.removeCurrentSnackBarm();
    RM.scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Text(ErrorHandler.getErrorMessage(error)),
            const Spacer(),
            const Icon(Icons.error_outline, color: Colors.yellow)
          ],
        ),
      ),
    );
  }
}
