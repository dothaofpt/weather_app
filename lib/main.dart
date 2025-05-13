import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather.dart';
import 'weather_service.dart';
import 'database_helper.dart';

void main() {
  print('Starting app, initializing database factory...');
  DatabaseHelper.initDatabaseFactory();
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dự báo thời tiết Hà Nội',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService _weatherService = WeatherService();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<Weather> _weatherList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    print('Initializing WeatherHomePage, loading weather...');
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('Fetching weather data from API...');
      final weatherData = await _weatherService.fetchWeather();
      print('Clearing old weather data...');
      await _databaseHelper.clearWeather();
      print('Inserting new weather data to SQLite...');
      for (var weather in weatherData) {
        await _databaseHelper.insertWeather(weather);
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      setState(() {
        _errorMessage = 'Lỗi khi lấy dữ liệu từ API: $e';
      });
    }

    try {
      print('Loading weather data from SQLite...');
      final weatherList = await _databaseHelper.getWeather();
      setState(() {
        _weatherList = weatherList;
        _isLoading = false;
        print('Loaded ${_weatherList.length} weather entries');
      });
    } catch (e) {
      print('Error loading from database: $e');
      setState(() {
        _errorMessage = 'Lỗi khi tải dữ liệu từ cơ sở dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dự báo thời tiết Hà Nội'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeather,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _weatherList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Không có dữ liệu thời tiết'),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _weatherList.length,
        itemBuilder: (context, index) {
          final weather = _weatherList[index];
          final dateTime = DateTime.parse(weather.dateTime);
          final dateFormat = DateFormat('EEEE, dd MMM yyyy').format(dateTime); // Hiển thị thứ và ngày
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.network(
                'http://openweathermap.org/img/wn/${weather.icon}@2x.png',
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
              ),
              title: Text(dateFormat),
              subtitle: Text(
                '${weather.temperature.toStringAsFixed(1)}°C, ${weather.description}\nĐộ ẩm: ${weather.humidity}%',
              ),
            ),
          );
        },
      ),
    );
  }
}