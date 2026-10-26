# Favorite Places

A simple Flutter app. Save places with a title, photo and location, view them on a map, and keep them after the app is closed.

## Features
- List of saved places with photo and address
- Add place with title, camera photo and location (current or picked on map)
- Place details with map preview and full map view
- Local storage with sqflite
- Input validation

## Setup
The app needs a Google Maps API key with Maps SDK for Android, Geocoding API and Maps Static API enabled.

1. Create `lib/secrets.dart`:
   ```dart
   const googleMapsApiKey = 'YOUR_API_KEY';
   ```
2. Add to `android/local.properties`:
   ```
   MAPS_API_KEY=YOUR_API_KEY
   ```
3. Run:
   ```
   flutter pub get
   flutter run
   ```
