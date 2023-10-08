// ignore: file_names
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'https://955e-2406-7400-81-cff7-401b-682d-c52-e4d5.ngrok-free.app/')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST('api/login/')
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);

  @POST('weather/dashboard/')
  Future<WeatherData> getDashboardData(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> body,
  );

  @POST('weather/forecast/')
  Future<List<WeatherData>> getForecastData(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> body,
  );

  @POST('weather/setPref')
  Future<void> setTemperaturePreferences(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> body,
  );

  @POST('api/register/')
  Future<void> register(@Body() Map<String, dynamic> body);
}

class LoginResponse {
  final String name;
  final String token;

  LoginResponse({required this.name, required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      name: json['username'],
      token: json['token'],
    );
  }
}

class WeatherData {
  final double temperature;
  final double windspeed;
  final double humidity;
  final double weathercode;
  final DateTime date; // Only for forecast

  // Private constructor that takes a date parameter
  WeatherData._({
    required this.temperature,
    required this.windspeed,
    required this.humidity,
    required this.weathercode,
    required this.date,
  });

  // Named constructor with a constant default date value
  WeatherData({
    required this.temperature,
    required this.windspeed,
    required this.humidity,
    required this.weathercode,
    DateTime? date,
  }) : date = date ?? DateTime(2023, 1, 1);

  factory WeatherData.fromJson(Map<String, dynamic> json) {
  if (json['data'] == null) {
    throw Exception('Invalid JSON data');
  }

  final data = json['data'];

  // Check if numeric fields are present and not null
  final temperature = data['temperature']  ?? 0.0;
  final windspeed = data['windspeed']  ?? 0.0;
  final humidity = data['humidity'] ?? 0.0;
  final weathercode = data['weathercode'] ?? 0.0;

  // Check if the date field is present and not null
  final date = data['date'] != null ? DateTime.parse(data['date']) : DateTime.now();

  return WeatherData._(
    temperature: temperature.toDouble(),
    windspeed: windspeed.toDouble(),
    humidity: humidity.toDouble(),
    weathercode: weathercode.toDouble(),
    date: date, 
  );
  }

}

