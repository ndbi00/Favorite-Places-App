import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/util/maps.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

import 'package:favorite_places/screens/map.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  bool _isGettingLocation = false;

  // Looks up address and passes the location up
  Future<void> _savePlace(double lat, double lng) async {
    setState(() => _isGettingLocation = true);
    try {
      final address = await getAddress(lat, lng);
      if (!mounted) return;
      setState(() {
        _pickedLocation = PlaceLocation(
          latitude: lat,
          longitude: lng,
          address: address,
        );
      });
      widget.onSelectLocation(_pickedLocation!);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get address. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    final location = Location();

    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    setState(() => _isGettingLocation = true);
    final data = await location.getLocation();
    final lat = data.latitude;
    final lng = data.longitude;

    if (lat == null || lng == null) {
      setState(() => _isGettingLocation = false);
      return;
    }
    await _savePlace(lat, lng);
  }

  Future<void> _selectOnMap() async {
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        // Start at the current choice if there is one
        builder: (ctx) => _pickedLocation == null
            ? const MapScreen()
            : MapScreen(location: _pickedLocation!),
      ),
    );
    if (picked == null) return;

    await _savePlace(picked.latitude, picked.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget preview = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
    );

    if (_pickedLocation != null) {
      preview = Image.network(
        staticMapUrl(_pickedLocation!.latitude, _pickedLocation!.longitude),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isGettingLocation) {
      preview = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: preview,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              onPressed: _isGettingLocation ? null : _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        ),
      ],
    );
  }
}