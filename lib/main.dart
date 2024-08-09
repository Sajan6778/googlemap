import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemap/firstpage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  final LatLng _initialPosition = LatLng(8.195016562680948, 77.37638344987191);
  String _weatherInfo = 'Loading...';
  bool _isCelsius = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(_initialPosition.latitude, _initialPosition.longitude);
  }

  Future<void> _fetchWeatherData(double lat, double lon) async {
    final apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=${_isCelsius ? 'metric' : 'imperial'}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _weatherInfo =
              'Temperature: ${data['main']['temp']} ${_isCelsius ? '°C' : '°F'}\n'
              'Weather: ${data['weather'][0]['description']}\n'
              'Min Temp: ${data['main']['temp_min']} ${_isCelsius ? '°C' : '°F'}\n'
              'Max Temp: ${data['main']['temp_max']} ${_isCelsius ? '°C' : '°F'}\n'
              'Wind Speed: ${data['wind']['speed']} ${_isCelsius ? 'm/s' : 'mph'}';
        });
      } else {
        setState(() {
          _weatherInfo = 'Failed to fetch weather data';
        });
      }
    } catch (e) {
      setState(() {
        _weatherInfo = 'Error: $e';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng position) {
    _fetchWeatherData(position.latitude, position.longitude);
  }

  void _onForecastButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForecastScreen(
          latitude: _initialPosition.latitude,
          longitude: _initialPosition.longitude,
        ),
      ),
    );
  }

  void _toggleTemperatureUnit() {
    setState(() {
      _isCelsius = !_isCelsius;
      _fetchWeatherData(_initialPosition.latitude, _initialPosition.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather Map')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 12,
              ),
              onMapCreated: _onMapCreated,
              onTap: _onMapTapped,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(_weatherInfo),
                ElevatedButton(
                  onPressed: _toggleTemperatureUnit,
                  child: Text(_isCelsius
                      ? 'Switch to Fahrenheit'
                      : 'Switch to Celsius'),
                ),
                ElevatedButton(
                  onPressed: _onForecastButtonPressed,
                  child: Text('View 5-Day Forecast'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
