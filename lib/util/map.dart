import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:favorite_places/secrets.dart';

// Static map image with a marker
String staticMapUrl(double lat, double lng) {
  return 'https://maps.googleapis.com/maps/api/staticmap'
      '?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap'
      '&markers=color:red%7Clabel:A%7C$lat,$lng'
      '&key=$googleMapsApiKey';
}

// Coordinates to readable address
Future<String> getAddress(double lat, double lng) async {
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/geocode/json'
    '?latlng=$lat,$lng&key=$googleMapsApiKey',
  );
  final response = await http.get(url);
  final data = json.decode(response.body);

  if (response.statusCode != 200 || data['status'] != 'OK') {
    throw Exception('Geocoding failed: ${data['status']}');
  }
  return data['results'][0]['formatted_address'];
}