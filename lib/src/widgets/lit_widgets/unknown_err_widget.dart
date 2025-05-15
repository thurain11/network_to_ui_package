import 'package:flutter/material.dart';

class UnknownErrWidget extends StatelessWidget {
  final Function? fun;
  final String? message;
  final double? widgetSize;

  const UnknownErrWidget(
      {super.key, this.fun, this.message, this.widgetSize = 300});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Center(
            child: message == null
                ? Text(
                    "Unknown Error!...",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  )
                : Text(
                    message!,
                    textAlign: TextAlign.center,
                  )),
        SizedBox(
          height: 20,
        ),
        fun == null
            ? Container()
            : Center(
                child: SizedBox(
                  height: 25,
                  child: ElevatedButton(
                    onPressed: () {
                      fun!();
                    },
                    child: Text(
                      "Try Again",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
