import 'package:flutter/material.dart';

/// Prevents the system back button / gesture from popping this route.
class DisableRoutePop extends StatelessWidget {
  const DisableRoutePop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: child);
  }
}
