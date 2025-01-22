import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  final String apiKey = '09a5755a40b0a9ea81c4bc68d48da0bf';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> getWeather(String city) async {
    final response = await http.get(
      Uri.parse('$baseUrl?q=$city,TR&units=metric&appid=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final condition = data['weather'][0]['main'].toString().toLowerCase();

      return Weather(
        city: data['name'],
        temperature: data['main']['temp'].toDouble(),
        animationAsset: _getAnimationAsset(condition),
      );
    } else {
      throw Exception('Hava durumu bilgisi alınamadı');
    }
  }

  String _getAnimationAsset(String condition) {
    switch (condition) {
      case 'rain':
      case 'drizzle':
        return 'assets/animations/rain.json';
      case 'snow':
        return 'assets/animations/snow.json';
      case 'clear':
        return 'assets/animations/sunny.json';
      case 'clouds':
        return 'assets/animations/cloudy.json';
      default:
        return 'assets/animations/sunny.json';
    }
  }
}
