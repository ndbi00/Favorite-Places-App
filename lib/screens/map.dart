import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:favorite_places/models/place.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 62.4723, // Default: Ålesund
      longitude: 6.1549,
      address: '',
    ),
    this.isSelecting = true,
  });

  final PlaceLocation location;
  final bool isSelecting; // true: pick, false: view only

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  @override
  Widget build(BuildContext context) {
    final initial = LatLng(widget.location.latitude, widget.location.longitude);

    // No marker until the user taps, when selecting
    final markers = (_pickedLocation == null && widget.isSelecting)
        ? <Marker>{}
        : {
            Marker(
              markerId: const MarkerId('m1'),
              position: _pickedLocation ?? initial,
            ),
          };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelecting ? 'Pick your Location' : 'Your Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _pickedLocation == null
                  ? null
                  : () => Navigator.of(context).pop(_pickedLocation),
            ),
        ],
      ),
      body: GoogleMap(
        onTap: !widget.isSelecting
            ? null
            : (position) => setState(() => _pickedLocation = position),
        initialCameraPosition: CameraPosition(target: initial, zoom: 16),
        markers: markers,
      ),
    );
  }
}