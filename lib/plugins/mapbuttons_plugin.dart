// ignore_for_file: dead_code

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';

class MapButtons extends StatelessWidget {
  final MapController mapController;
  final double minZoom;
  final double maxZoom;
  final IconData zoomInIcon;
  final IconData zoomOutIcon;
  final bool isCurrentLocation;
  final Function() onPressed;

  const MapButtons({
    super.key,
    required this.mapController,
    this.minZoom = 1,
    this.maxZoom = 18,
    this.zoomInIcon = Icons.add,
    this.zoomOutIcon = Icons.remove,
    this.isCurrentLocation = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);

    return Stack(
      children: [
        Positioned(
          bottom: 110,
          right: 15,
          child: SizedBox(
            height: 80,
            child: FloatingActionButton(
                onPressed: null,
                backgroundColor: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          final zoom = min(camera.zoom + 1, maxZoom);
                          mapController.move(camera.center, zoom);
                        },
                        icon: Icon(zoomInIcon),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () async {
                          final zoom = max(camera.zoom - 1, minZoom);
                          mapController.move(camera.center, zoom);
                        },
                        icon: Icon(zoomOutIcon),
                      ),
                    ),
                  ],
                )),
          ),
        ),
        Positioned(
          bottom: 30,
          right: 15,
          child: FloatingActionButton(
            onPressed: () => onPressed(),
            backgroundColor: Colors.white,
            shape: const CircleBorder(),
            child: SvgPicture.asset(
              isCurrentLocation
                  ? 'assets/icons/fill_navigate.svg'
                  : 'assets/icons/navigate.svg',
            ),
          ),
        ),
      ],
    );
  }
}
