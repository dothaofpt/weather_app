import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather.dart';
import 'weather_service.dart';
import 'database_helper.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hanoi Weather Forecast',
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

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to fetch from API
      final weatherData = await _weatherService.fetchWeather();
      // Clear old data
      await _databaseHelper.clearWeather();
      // Save new data to SQLite
      for (var weather in weatherData) {
        await _databaseHelper.insertWeather(weather);
      }
    } catch (e) {
      // If API fails, load from SQLite
      print('Error fetching weather: $e');
    }

    // Load data from SQLite
    final weatherList = await _databaseHelper.getWeather();
    setState(() {
      _weatherList = weatherList;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hanoi Weather Forecast'),
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
              ? const Center(child: Text('No weather data available'))
              : ListView.builder(
                  itemCount: _weatherList.length,
                  itemBuilder: (context, index) {
                    final weather = _weatherList[index];
                    final dateTime =
                        DateFormat('MMM dd, yyyy HH:mm').format(
                            DateTime.parse(weather.dateTime));
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Image.network(
                          'http://openweathermap.org/img/wn/${weather.icon}.png',
                          width: 50,
                          height: 50,
                        ),
                        title: Text('$dateTime'),
                        subtitle: Text(
                          '${weather.temperature}°C, ${weather.description}\nHumidity: ${weather.humidity}%',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}