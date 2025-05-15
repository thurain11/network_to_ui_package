import 'package:flutter/material.dart';

import '../../utils/response_ob.dart'; // Assuming ErrState is defined here

class ErrWidget extends StatelessWidget {
  final ErrState errState; // Non-final field causing warning
  final VoidCallback? func; // Non-final field causing warning

  const ErrWidget({super.key, required this.errState, this.func});

  @override
  Widget build(BuildContext context) {
    // Error UI rendering logic based on errState
    return Column(
      children: [
        Text(errState.toString()),
        if (func != null)
          ElevatedButton(
            onPressed: func,
            child: Text('Retry'),
          ),
      ],
    );
  }
}
