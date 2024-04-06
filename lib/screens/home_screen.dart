import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import 'package:way_finder/app.dart';
import 'package:way_finder/constants/api_constant.dart';
import 'package:way_finder/misc/tile_providers.dart';
import 'package:latlong2/latlong.dart';
import 'package:way_finder/plugins/mapbuttons_plugin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';
  late final MapController mapController;
  StreamSubscription<LocationData>? locationSubscription;
  bool isCurrentLocation = false;
  TextEditingController search = TextEditingController(text: '');
  FocusNode searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final Dio _dio = Dio();
  List suggestions = [];
  bool showSuggestion = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    listenLocation();
  }

  @override
  void dispose() {
    mapController.dispose();
    locationSubscription?.cancel();
    setState(() {
      locationSubscription = null;
    });
    searchFocusNode.dispose();
    super.dispose();
  }

  bool isSimulator() {
    if (Platform.isAndroid || Platform.isIOS) {
      return Platform.environment['SIMULATOR'] != null ||
          Platform.environment['EMULATOR'] != null;
    } else {
      return false;
    }
  }

  Future<void> listenLocation() async {
    await location.changeSettings(distanceFilter: 10);

    locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      locationSubscription?.cancel();
      setState(() {
        locationSubscription = null;
      });
    }).listen((currentLocation) {
      setState(() {
        latitude = currentLocation.latitude!;
        longitude = currentLocation.longitude!;
      });
    });
  }

  void _animatedMapMove(double latitude, double longitude, double destZoom) {
    final camera = mapController.camera;
    final latTween =
        Tween<double>(begin: camera.center.latitude, end: latitude);
    final lngTween =
        Tween<double>(begin: camera.center.longitude, end: longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    final startIdWithTarget = '$_startedId#$latitude,$longitude,$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  getSuggestionAddress() async {
    try {
      setState(() {
        showSuggestion = false;
      });
      final response = await _dio.get(
        ApiConstant.ADDRESS_URL,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        queryParameters: {
          'q': search.text,
          'limit': 10,
        },
      );
      suggestions = [];
      if (response.data.isNotEmpty) {
        suggestions = response.data['features'];
      }
      setState(() {
        showSuggestion = true;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  getAddress(properties) {
    String district = properties['district'] ?? "";
    String state = properties['state'] ?? "";
    String city = properties['city'] ?? "";
    String country = properties['country'] ?? "";
    if (district.isNotEmpty) district += ', ';
    if (state.isNotEmpty) state += ', ';
    if (city.isNotEmpty) city += ', ';
    return '$district$state$city$country';
  }

  suggestionCard(index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showSuggestion = false;
          search.text = suggestions[index]['properties']['name'].toString();
        });
        _animatedMapMove(suggestions[index]['geometry']['coordinates'][0],
            suggestions[index]['geometry']['coordinates'][1], 16.5);
      },
      child: Column(
        children: [
          ListTile(
            title: Text(
              suggestions[index]['properties']['name'].toString(),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            subtitle: Text(
              getAddress(suggestions[index]['properties']),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          if (index < suggestions.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Divider(
                height: 0,
                color: Colors.grey,
                thickness: 0.3,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        searchFocusNode.unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(latitude, longitude),
                initialZoom: 16.5,
                onPositionChanged: (position, hasGesture) {
                  setState(() {
                    isCurrentLocation = false;
                  });
                },
              ),
              children: [
                openStreetMapTileLayer,
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(latitude, longitude),
                      color: const Color(0xff007AFF),
                      borderColor: Colors.white,
                      borderStrokeWidth: 4,
                      useRadiusInMeter: true,
                      radius: 10,
                    ),
                    CircleMarker(
                      point: LatLng(latitude, longitude),
                      color: const Color(0xff007AFF).withOpacity(0.3),
                      borderStrokeWidth: 0,
                      useRadiusInMeter: true,
                      radius: 70,
                    ),
                  ],
                ),
                MapButtons(
                  mapController: mapController,
                  minZoom: 4,
                  maxZoom: 19,
                  isCurrentLocation: isCurrentLocation,
                  onPressed: () {
                    setState(() {
                      isCurrentLocation = true;
                    });
                    _animatedMapMove(latitude, longitude, 16.5);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 64,
              ),
              child: TextFormField(
                key: const Key("search"),
                controller: search,
                focusNode: searchFocusNode,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                style: Theme.of(context).textTheme.bodyLarge,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  hintText: 'Search Maps',
                  suffixIcon: IconButton(
                    onPressed: () async {
                      searchFocusNode.unfocus();
                      getSuggestionAddress();
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/search.svg',
                    ),
                  ),
                ),
              ),
            ),
            if (showSuggestion)
              Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 120,
                  bottom: 250,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      return suggestionCard(index);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
