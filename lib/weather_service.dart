import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather.dart';

class WeatherService {
  static const String _apiKey = '8d7715ecb6e05b33bc4656cb0ea95087';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  Future<List<Weather>> fetchWeather() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?q=Hanoi&appid=$_apiKey&units=metric'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> weatherList = jsonData['list'] ?? [];

        // Lọc để lấy bản ghi gần 12:00 mỗi ngày
        final List<Weather> dailyWeather = [];
        final Map<String, Weather> dailyMap = {};

        for (var json in weatherList) {
          final weather = Weather.fromJson(json);
          final dateTime = DateTime.parse(weather.dateTime);
          final dateKey = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

          // Chọn bản ghi gần 12:00 trưa
          if (dateTime.hour >= 11 && dateTime.hour <= 13) {
            if (!dailyMap.containsKey(dateKey)) {
              dailyMap[dateKey] = weather;
            }
          }
        }

        // Chuyển map thành danh sách và giới hạn 5 ngày
        dailyWeather.addAll(dailyMap.values.take(5));
        return dailyWeather;
      } else if (response.statusCode == 401) {
        throw Exception('Khóa API không hợp lệ. Vui lòng kiểm tra khóa API.');
      } else {
        throw Exception('Không thể tải dữ liệu thời tiết: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }
}