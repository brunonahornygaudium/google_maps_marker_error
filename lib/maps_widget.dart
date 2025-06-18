import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_marker_error/latlng_tween.dart';
import 'package:google_maps_marker_error/maps_util.dart';

class MapsWidget extends StatefulWidget {
  const MapsWidget({super.key});

  @override
  State<MapsWidget> createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> with TickerProviderStateMixin {
  late GoogleMapController _controller;
  final initialPosition = LatLng(-27.598065, -48.565579);
  Marker? driverMarker;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;

    initializeMarkers();
  }

  void _animateMarkerToRandomPosition() {
    if (driverMarker == null) {
      return;
    }

    animationController?.dispose();
    animationController = null;

    final randomLat = initialPosition.latitude + (Random().nextDouble() * 0.1);
    final randomLng = initialPosition.longitude + (Random().nextDouble() * 0.1);
    final newPosition = LatLng(randomLat, randomLng);

    final tween = LatLngTween(begin: driverMarker!.position, end: newPosition);

    animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    final animation = tween.animate(animationController!);

    animationController!.addListener(() {
      final position = animation.value;
      // _controller.animateCamera(CameraUpdate.newLatLng(position));

      setState(() {
        driverMarker = driverMarker!.copyWith(
          positionParam: position,
          visibleParam: true,
        );
        _markers.add(driverMarker!);
      });
    });

    animationController!.forward();
  }

  final _markers = <Marker>{};

  AnimationController? animationController;

  Future<void> initializeMarkers() async {
    driverMarker = await setupMarker(context: context, latLng: initialPosition);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 15.0,
          ),

          onMapCreated: _onMapCreated,
          padding: const EdgeInsets.all(8.0),
          markers: _markers,
        ),

        Positioned(
          right: 8,
          bottom: 80,
          child: FloatingActionButton(
            onPressed: _animateMarkerToRandomPosition,
            child: Icon(Icons.swap_calls),
          ),
        ),
      ],
    );
  }
}
