import 'package:flutter/material.dart';
import 'package:ticketing_flutter/auth/login.dart';
import 'package:ticketing_flutter/services/user_service.dart';

/// Clears the session and resets navigation to the login screen.
/// Call after the drawer has been closed (e.g. `Navigator.pop` for the drawer).
Future<void> logoutUserAndShowLogin(BuildContext context) async {
  await UserService().logout();
  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}
