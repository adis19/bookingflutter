import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import '../services/weather_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class WeatherTestScreen extends StatefulWidget {
  const WeatherTestScreen({Key? key}) : super(key: key);

  @override
  State<WeatherTestScreen> createState() => _WeatherTestScreenState();
}

class _WeatherTestScreenState extends State<WeatherTestScreen> {
  final WeatherService _weatherService = WeatherService();
  Weather? _currentWeather;
  String _status = 'Загрузка данных о погоде...';
  bool _isLoading = false;
  final TextEditingController _cityController = TextEditingController(text: 'Бишкек');
  
  @override
  void initState() {
    super.initState();
    _loadWeather();
  }
  
  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
  
  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _status = 'Загрузка данных о погоде...';
    });
    
    try {
      final weather = await _weatherService.getWeatherByCity(_cityController.text);
      setState(() {
        _currentWeather = weather;
        _isLoading = false;
        _status = 'Данные о погоде успешно загружены';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Ошибка при загрузке данных о погоде: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Тест API погоды'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Город',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _loadWeather,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    elevation: 3,
                    shadowColor: AppConstants.primaryColor.withOpacity(0.3),
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(
                color: _status.contains('Ошибка') ? Colors.red : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_currentWeather != null)
              _buildWeatherInfo(_currentWeather!),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeatherInfo(Weather weather) {
    final iconCode = weather.weatherIcon ?? '';
    final tempC = weather.temperature?.celsius?.toStringAsFixed(1) ?? 'N/A';
    final description = weather.weatherDescription ?? 'Нет данных';
    final humidity = weather.humidity?.toString() ?? 'N/A';
    final windSpeed = weather.windSpeed?.toString() ?? 'N/A';
    final cityName = weather.areaName ?? 'Неизвестный город';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cityName,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textColor,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: AppConstants.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://openweathermap.org/img/wn/$iconCode@2x.png',
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.error,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        '$tempC°C',
                        style: GoogleFonts.montserrat(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(
              color: Colors.blue,
              thickness: 0.5,
              height: 1,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(Icons.water_drop, 'Влажность', '$humidity%'),
                _buildWeatherDetail(Icons.air, 'Ветер', '$windSpeed м/с'),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.blue.shade300,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Источник данных: ${_weatherService.useBackend ? 'Бэкенд API' : 'OpenWeatherMap API'}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.blue.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppConstants.primaryColor,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: AppConstants.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.textColor,
            ),
          ),
        ],
      ),
    );
  }
} 