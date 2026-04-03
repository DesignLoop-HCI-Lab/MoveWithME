import 'dart:convert';
import 'package:http/http.dart' as http;

class EspService {
  final String url = "http://192.168.4.1/status";

  Future<String?> fetchMovement() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["movement"];
      }
    } catch (e) {
      // ignore errors
    }

    return null;
  }
}