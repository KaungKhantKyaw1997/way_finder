// ignore_for_file: dead_code

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapButtons extends StatelessWidget {
  final MapController mapController;
  final double minZoom;
  final double maxZoom;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;

  const MapButtons({
    super.key,
    required this.mapController,
    this.minZoom = 1,
    this.maxZoom = 18,
    this.zoomInIcon = Icons.add,
    this.zoomOutIcon = Icons.remove,
  });

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.only(
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              mini: true,
              elevation: 0.1,
              backgroundColor: Colors.white.withOpacity(
                0.9,
              ),
              shape: const CircleBorder(),
              onPressed: () async {
                final zoom = min(camera.zoom + 1, maxZoom);
                mapController.move(camera.center, zoom);
              },
              child: Icon(
                zoomInIcon,
                size: 16,
              ),
            ),
            FloatingActionButton(
              mini: true,
              elevation: 0.1,
              backgroundColor: Colors.white.withOpacity(
                0.9,
              ),
              shape: const CircleBorder(),
              onPressed: () async {
                final zoom = max(camera.zoom - 1, minZoom);
                mapController.move(camera.center, zoom);
              },
              child: Icon(
                zoomOutIcon,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
