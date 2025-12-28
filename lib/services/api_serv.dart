import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8000/api";

  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["token"];
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getGeo(String ip) async {
    final url = ip.isEmpty
        ? "https://ipinfo.io/geo"
        : "https://ipinfo.io/$ip/geo";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
