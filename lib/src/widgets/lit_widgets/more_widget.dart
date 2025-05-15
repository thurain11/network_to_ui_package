import 'package:flutter/material.dart';

class MoreWidget extends StatelessWidget {
  dynamic data; // Non-final field causing must_be_immutable warning

  MoreWidget({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example rendering for "No more data" or load more UI
    return Center(
      child: Text("No more data found.\""), // Unnecessary escape in string
    );
  }
}
