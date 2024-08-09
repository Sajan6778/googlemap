import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class ForecastScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  ForecastScreen({required this.latitude, required this.longitude});

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<dynamic> _forecast = [];

  @override
  void initState() {
    super.initState();
    _fetchForecastData(widget.latitude, widget.longitude);
  }

  Future<void> _fetchForecastData(double lat, double lon) async {
    final apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
    final url = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _forecast = data['list'];
        });
      } else {
        setState(() {
          _forecast = [];
        });
      }
    } catch (e) {
      setState(() {
        _forecast = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('5-Day Forecast')),
      body: ListView.builder(
        itemCount: _forecast.length,
        itemBuilder: (context, index) {
          final item = _forecast[index];
          final date = DateTime.parse(item['dt_txt']);
          final temp = item['main']['temp'];
          final weather = item['weather'][0]['description'];
          final minTemp = item['main']['temp_min'];
          final maxTemp = item['main']['temp_max'];

          return ListTile(
            title: Text('${date.toLocal()}'),
            subtitle: Text('Weather: $weather\n'
                'Min Temp: $minTemp °C\n'
                'Max Temp: $maxTemp °C\n'
                'Temperature: $temp °C'),
          );
        },
      ),
    );
  }
}