import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required final LatLng begin, required final LatLng end})
    : super(begin: begin, end: end);

  @override
  LatLng lerp(final double t) {
    return LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}
