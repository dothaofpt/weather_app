class Weather {
  final String dateTime;
  final double temperature;
  final int humidity;
  final String description;
  final String icon;

  Weather({
    required this.dateTime,
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime,
      'temperature': temperature,
      'humidity': humidity,
      'description': description,
      'icon': icon,
    };
  }

  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      dateTime: map['dateTime'] ?? '',
      temperature: (map['temperature'] as num).toDouble(),
      humidity: map['humidity'] ?? 0,
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
    );
  }

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      dateTime: json['dt_txt'] ?? '',
      temperature: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      humidity: json['main']['humidity'] ?? 0,
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
    );
  }
}