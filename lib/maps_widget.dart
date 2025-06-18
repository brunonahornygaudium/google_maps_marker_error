import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_marker_error/latlng_tween.dart';
import 'package:google_maps_marker_error/maps_util.dart';

class MapsWidget extends StatefulWidget {
  const MapsWidget({super.key});

  @override
  State<MapsWidget> createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget>
    with SingleTickerProviderStateMixin {
  late GoogleMapController _controller;
  final initialPosition = LatLng(-24.24, -24.24);
  Marker? driverMarker;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;

    initializeMarkers();
  }

  void _animateMarkerToRandomPosition() {
    if (driverMarker == null) {
      return;
    }

    final randomLat = initialPosition.latitude + (0.01 * (0.5 - 1));
    final randomLng = initialPosition.longitude + (0.01 * (0.5 - 1));
    final newPosition = LatLng(randomLat, randomLng);

    final tween = LatLngTween(begin: driverMarker!.position, end: newPosition);

    animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    final animation = tween.animate(animationController!);

    animationController!.addListener(() {
      final position = animation.value;
      _controller.animateCamera(CameraUpdate.newLatLng(position));

      setState(() {
        driverMarker = driverMarker!.copyWith(
          positionParam: position,
          visibleParam: true,
        );
        _markers.add(driverMarker!);
      });
    });
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
        Positioned(
          child: IconButton(
            onPressed: _animateMarkerToRandomPosition,
            icon: Icon(Icons.swap_calls),
          ),
        ),
        GoogleMap(
          initialCameraPosition: CameraPosition(target: initialPosition),
          onMapCreated: _onMapCreated,
          padding: const EdgeInsets.all(8.0),
          markers: _markers,
        ),
      ],
    );
  }
}
