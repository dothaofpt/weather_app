import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather.dart';

class WeatherService {
  static const String _apiKey = 'af2894a2715d8a915d21f7b694fdb44c'; // Thay bằng API key của bạn
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/forecast';

  Future<List<Weather>> fetchWeather() async {
    final response = await http.get(Uri.parse(
        '$_baseUrl?q=Hanoi&appid=$_apiKey&units=metric'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> weatherList = jsonData['list'];
      return weatherList.map((json) => Weather.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}