import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../models/weather.dart';
import 'city_picker.dart';

class WeatherCard extends StatelessWidget {
  final Weather? currentWeather;
  final String selectedCity;
  final Function(String) onCitySelect;

  const WeatherCard({
    super.key,
    required this.currentWeather,
    required this.selectedCity,
    required this.onCitySelect,
  });

  void _showCityPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CityPicker(
          onCitySelected: onCitySelect,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentWeather?.city ?? selectedCity} Hava Durumu',
                  style: const TextStyle(fontSize: 18),
                ),
                TextButton(
                  onPressed: () => _showCityPicker(context),
                  child: const Text('Şehir Seç'),
                ),
              ],
            ),
            if (currentWeather != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Lottie.asset(
                      currentWeather!.animationAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${currentWeather!.temperature.round()}°',
                    style: const TextStyle(fontSize: 32),
                  ),
                ],
              ),
            ] else
              const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
