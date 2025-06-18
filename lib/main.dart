import 'package:flutter/material.dart';
import 'package:google_maps_marker_error/maps_widget.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Google Maps Marker Error',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(body: const MapsWidget()),
    ),
  );
}
