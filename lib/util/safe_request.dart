import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Suppose you have an authProvider that lets you log out:
import 'package:film_randomizer/notifiers/auth_notifier.dart';

/// A helper function that intercepts HTTP requests,
/// checks for an unauthorized message, and logs out if needed.
/// 
/// [makeRequest] is a callback that actually performs the HTTP call.
/// [ref] is your Riverpod ref, so you can log out if needed.
Future<http.Response> safeRequest(
  Future<http.Response> Function() makeRequest,
  Ref ref,
) async {
  final response = await makeRequest();

  // If your backend sends a 401 or a specific message, handle it:
  if (response.statusCode == 401) {
    // Possibly parse the JSON to see if it has the "Not authorized, token failed" message
    final body = jsonDecode(response.body);
    if (body['message'] == "Not authorized, token failed") {
      // call logout
      ref.read(authProvider.notifier).logout();
    }
  }

  return response;
}
