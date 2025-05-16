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
      case ErrState.invalidResponse:
        message = 'Invalid response from server';
        break;
      case ErrState.serverError:
        message = 'Server error, please try again later';
        break;
      case ErrState.serverMaintain:
        message = 'Server under maintenance';
        break;
      case ErrState.notFound:
        message = 'Resource not found';
        break;
      case ErrState.unAuth:
        message = 'Unauthorized access';
        break;
      case ErrState.rateLimit:
        message = 'Rate limit exceeded';
        break;
      case ErrState.noInternet:
        message = 'No internet connection';
        break;
      case ErrState.cancelled:
        message = 'Request cancelled';
        break;
      case ErrState.validateError:
        message = 'Validation error';
        break;
      case ErrState.unknownError:
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
