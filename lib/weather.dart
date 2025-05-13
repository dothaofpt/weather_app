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

  // Convert Weather object to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime,
      'temperature': temperature,
      'humidity': humidity,
      'description': description,
      'icon': icon,
    };
  }

  // Create Weather object from Map
  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      dateTime: map['dateTime'],
      temperature: map['temperature'],
      humidity: map['humidity'],
      description: map['description'],
      icon: map['icon'],
    );
  }

  // Create Weather object from API JSON
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      dateTime: json['dt_txt'],
      temperature: json['main']['temp'].toDouble(),
      humidity: json['main']['humidity'],
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}