import 'package:flutter/material.dart';

import '../../utils/response_ob.dart';
import 'unknown_err_widget.dart';

class ErrWidget extends StatelessWidget {
  ErrState? errState;
  Function func;

  ErrWidget(this.errState, this.func, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: error(),
    );
  }

  Widget error() {
    if (errState == ErrState.no_internet) {
      return Column(
        children: [
          Center(
            child: Text(
              "Check your internet connection and try again!",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 25,
                  child: ElevatedButton(
                    onPressed: () {
                      func();
                    },
                    child: Text(
                      "Try Again",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (errState == ErrState.no_login) {
      return Column(
        children: [
          Center(child: Text("You need to login to continue")),
        ],
      );
    } else if (errState == ErrState.not_found) {
      return Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              '404 NOT FOUND',
              style: TextStyle(fontSize: 17),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              "Oops!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              "We couldn\'t find the page you looking for",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else if (errState == ErrState.connection_timeout) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.info_outline,
            color: Colors.red,
          ),
          const SizedBox(
            height: 20,
          ),
          const Center(child: Text("The connection has timeout....")),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                func();
              },
              child: const Text(
                "Try Again",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      );
    } else if (errState == ErrState.too_many_request) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            color: Colors.red,
          ),
          SizedBox(
            height: 20,
          ),
          Center(child: Text("Too Many Request! Please Try Again Later")),
        ],
      );
    } else if (errState == ErrState.server_error) {
      return Column(
        children: [
          Center(
            child: Text(
              '500 INTERNAL SERVER ERROR!',
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      );
    } else if (errState == ErrState.server_maintain) {
      return Column(
        children: [
          Center(
            child: Text(
              "System Maintenance...",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
          ),
          Center(
              child:
                  Text("Service Unavailable", style: TextStyle(fontSize: 15))),
        ],
      );
    } else if (errState == ErrState.unknown_err) {
      return UnknownErrWidget(
        fun: () {
          func();
        },
      );
    } else {
      return UnknownErrWidget(
        fun: () {
          func();
        },
      );
    }
  }
}
