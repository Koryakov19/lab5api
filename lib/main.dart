import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(NetworkingApp());

class NetworkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Networking',
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    WeatherScreen(key: UniqueKey(), city: 'London,uk'),
    WeatherScreen(key: UniqueKey(), city: 'Oxford,uk'),
    WeatherScreen(key: UniqueKey(), city: 'Moscow,ru'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Networking'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'London',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Oxford',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Moscow',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  final String city;

  WeatherScreen({Key? key, required this.city}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<WeatherData> futureWeatherData;

  @override
  void initState() {
    super.initState();
    futureWeatherData = fetchWeather(widget.city);
  }

  @override
  void didUpdateWidget(WeatherScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.city != oldWidget.city) {
      setState(() {
        futureWeatherData = fetchWeather(widget.city);
      });
    }
  }

  Future<WeatherData> fetchWeather(String city) async {
    final apiKey = '12a9e16a295c9e78488706d822a9c415';
    final requestUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&APPID=$apiKey&units=metric&lang=ru';
    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode == 200) {
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherData>(
      future: futureWeatherData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return Text('Данные о погоде недоступны');
        }


        return WeatherInfo(weatherData: snapshot.data!);
      },
    );
  }
}

class WeatherData {
  final String description;
  final double temperature;
  final double windSpeed;
  final String main;
  final String icon;

  WeatherData({
    required this.description,
    required this.temperature,
    required this.windSpeed,
    required this.main,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      description: json['weather'][0]['description'],
      temperature: json['main']['temp'],
      windSpeed: json['wind']['speed'],
      main: json['weather'][0]['main'],
      icon: json['weather'][0]['icon'],
    );
  }
}

class WeatherInfo extends StatelessWidget {
  final WeatherData weatherData;

  WeatherInfo({required this.weatherData});@override
  Widget build(BuildContext context) {
    var bgColor = Colors.blue; // Значение по умолчанию
    if (weatherData.main.toLowerCase().contains('облачно')) {
      bgColor = Colors.grey;
    } else if (weatherData.main.toLowerCase().contains('дождь')) {
      bgColor = Colors.blueGrey;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'https://openweathermap.org/img/w/${weatherData.icon}.png',
              width: 100,
            ),
            Text(
              weatherData.main,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${weatherData.temperature.toStringAsFixed(1)}°C',
              style: TextStyle(fontSize: 64, color: Colors.white),
            ),
            Text(
              weatherData.description,
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            Text(
              'Ветер: ${weatherData.windSpeed.toStringAsFixed(1)} м/с',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}