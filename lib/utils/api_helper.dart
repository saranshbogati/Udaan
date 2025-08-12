import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.0.91:8000';

  Future<dynamic> getColleges() async {
    final url =
        Uri.parse('$baseUrl/colleges'); // update with your real endpoint path
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // decode json response
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load colleges');
    }
  }

  // add other endpoints similarly (POST, PUT, DELETE)
}
