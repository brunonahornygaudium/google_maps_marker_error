import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Marker> setupMarker({
  required final BuildContext context,
  required final LatLng latLng,
}) async {
  final bitmapDescriptor = await bitmapDescriptorFromSvgAsset(context: context);

  if (bitmapDescriptor == null) {
    log('Erro ao carregar o marcador');
  }

  final icon =
      bitmapDescriptor ??
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

  return Marker(
    markerId: MarkerId('driver_marker'),
    position: latLng,
    anchor: Offset(0.5, 0.95),
    visible: false,
    icon: icon,
  );
}

Future<BitmapDescriptor?> bitmapDescriptorFromSvgAsset({
  required final BuildContext context,
}) async {
  final size = Size(59, 67);

  // Carregar SVG com as cores do tema
  final svgContent = await rootBundle.loadString('driver.svg');
  final pictureInfo = await vg.loadPicture(
    SvgStringLoader(svgContent),
    null,
    clipViewbox: true,
  );

  // Converter SVG em imagem, com espaço extra para a sombra
  final image = await pictureInfo.picture.toImage(
    pictureInfo.size.width.toInt() + 8,
    pictureInfo.size.height.toInt() + 8,
  );
  pictureInfo.picture.dispose();

  // Preparar a pintura da sombra
  final Paint? shadowPaint;

  final scaleX = image.width / size.width;
  final scaleY = image.height / size.height;

  shadowPaint =
      Paint()
        ..colorFilter = const ui.ColorFilter.mode(
          Colors.black,
          ui.BlendMode.srcIn,
        )
        ..color = genericSmallShadow.color
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: genericSmallShadow.blurSigma * scaleX,
          sigmaY: genericSmallShadow.blurSigma * scaleY,
        );

  // Preparar Canvas
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder)..saveLayer(
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    Paint(),
  );

  // Desenhar as imagens no canvas
  canvas.drawImage(image, const Offset(4, 4), shadowPaint);
  canvas
    ..drawImage(image, const Offset(4, 4), Paint())
    ..restore();

  // Preparar o painter
  final painter = TextPainter(
    text: const TextSpan(),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(
    canvas,
    Offset(
      (image.width - painter.width) * 0.5,
      (image.height - painter.height) * 0.5,
    ),
  );

  // Converter o canvas em imagem
  final markerImage = await pictureRecorder.endRecording().toImage(
    image.width,
    image.height,
  );
  final byteData = await markerImage.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    return null;
  }

  return BitmapDescriptor.bytes(
    byteData.buffer.asUint8List(),
    //imagePixelRatio: scale,
    height: size.height + 4,
    width: size.width + 4,
  );
}

const genericSmallShadow = BoxShadow(
  color: shadow16,
  blurRadius: 4,
  spreadRadius: 0,
);

const shadow16 = Color(0x29000000);
