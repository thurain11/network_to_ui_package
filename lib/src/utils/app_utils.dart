import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'response_ob.dart';

class AppUtils {
  static void showToast({
    required String message,
    bool isError = false,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void checkError({
    required BuildContext? context,
    required ResponseOb responseOb,
  }) {
    String message;
    switch (responseOb.errState) {
      case ErrState.invalid_response:
        message = 'Invalid response from server';
        break;
      case ErrState.server_error:
        message = 'Server error, please try again later';
        break;
      case ErrState.maintainance:
        message = 'Server under maintenance';
        break;
      case ErrState.not_found:
        message = 'Resource not found';
        break;
      case ErrState.unauth:
        message = 'Unauthorized access';
        break;
      case ErrState.rate_limit:
        message = 'Rate limit exceeded';
        break;
      case ErrState.no_internet:
        message = 'No internet connection';
        break;
      case ErrState.cancelled:
        message = 'Request cancelled';
        break;
      case ErrState.validate_err:
        message = 'Validation error';
        break;
      case ErrState.unknown_err:
      default:
        message = 'An unknown error occurred';
        break;
    }
    showToast(message: message, isError: true);
  }

  static void moreResponse(ResponseOb resp, BuildContext context) {
    // Existing moreResponse logic (unchanged)
  }
}
