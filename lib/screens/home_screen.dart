import 'dart:async';
import 'dart:math';
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
  List coordinates = [];
  List<LatLng> directions = [];
  double endLatitude = 0.0;
  double endLongitude = 0.0;
  double duration = 0.0;
  double distance = 0.0;
  bool checkCar = true;
  bool checkBicycle = false;
  bool checkFoot = false;
  final LatLng startingPoint =
      LatLng(16.844936, 96.132378); // Starting point coordinates
  List<Map<String, dynamic>> intersections = [
    // List of intersections
    {
      "location": LatLng(16.844936, 96.132378),
      "bearings": [45, 135, 225],
      "maneuver": {"modifier": "left"}
    },
    // Add more intersections as needed
  ];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    // listenLocation();
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

  reverseCalc(double lat, double lng, double brng, double distance) {
    final R = 6371e3; // Earth's radius in meters
    final lat1 = lat * pi / 180; // Convert latitude to radians
    final lng1 = lng * pi / 180; // Convert longitude to radians
    final brngRad = brng * pi / 180; // Convert bearing to radians

    final lat2 = asin(sin(lat1) * cos(distance / R) +
        cos(lat1) * sin(distance / R) * cos(brngRad));
    final lng2 = lng1 +
        atan2(sin(brngRad) * sin(distance / R) * cos(lat1),
            cos(distance / R) - sin(lat1) * sin(lat2));

    // Convert back from radians to degrees
    final lat2Deg = lat2 * 180 / pi;
    final lng2Deg = lng2 * 180 / pi;

    return '${lat2Deg}, ${lng2Deg}';
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
          'limit': 20,
        },
      );
      if (response.statusCode == 200) {
        suggestions = [];
        if (response.data.isNotEmpty) {
          suggestions = response.data['features'];
        }
        setState(() {
          showSuggestion = true;
        });
      } else {
        throw Exception('Failed to get suggestion address');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getRoute() async {
    try {
      String origin = '$longitude,$latitude';
      String destination = '${coordinates[0]},${coordinates[1]}';

      String routeType = checkCar
          ? 'driving-car'
          : checkBicycle
              ? 'cycling-regular'
              : 'foot-walking';
      var response = await _dio.get(
        '${ApiConstant.DIRECTION_URL}/$routeType?api_key=${ApiConstant.DIRECTION_API_KEY}&start=$origin&end=$destination',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      if (response.statusCode == 200) {
        directions = [];
        endLatitude = 0.0;
        endLongitude = 0.0;
        if (response.data.isNotEmpty) {
          duration =
              response.data['features'][0]['properties']['summary']['duration'];
          distance =
              response.data['features'][0]['properties']['summary']['distance'];
          final List coordinates =
              response.data['features'][0]['geometry']['coordinates'];
          for (var coordinate in coordinates) {
            directions.add(LatLng(coordinate[1], coordinate[0]));
          }
          endLatitude = directions[directions.length - 1].latitude;
          endLongitude = directions[directions.length - 1].longitude;
        }
        setState(() {});
      } else {
        throw Exception('Failed to get directions');
      }
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

  String metersToKilometers(meters) {
    double kilometers = meters / 1000;
    return '${kilometers.toStringAsFixed(1)} km';
  }

  String secondsToHoursMinutesSeconds(double seconds) {
    int totalSeconds = seconds.toInt();
    int hours = (totalSeconds ~/ 3600);
    int remainingSeconds = totalSeconds % 3600;
    int minutes = (remainingSeconds ~/ 60);
    int remainingSecondsFinal = remainingSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSecondsFinal.toString().padLeft(2, '0')}';
  }

  suggestionCard(index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showSuggestion = false;
          search.text = suggestions[index]['properties']['name'].toString();
        });
        coordinates = suggestions[index]['geometry']['coordinates'];
        getRoute();
      },
      child: Column(
        children: [
          ListTile(
            title: Text(
              suggestions[index]['properties']['name'] ?? "",
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

  Marker buildEndPin(LatLng point) => Marker(
        point: point,
        width: 30,
        height: 30,
        child: SvgPicture.asset(
          "assets/icons/end_location.svg",
        ),
      );

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
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: directions,
                      strokeWidth: 10,
                      color: const Color(0xff60B593).withOpacity(0.7),
                      borderStrokeWidth: 0,
                    ),
                  ],
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(latitude, longitude),
                      color: const Color(0xff007AFF),
                      borderColor: Colors.white,
                      borderStrokeWidth: 3,
                      useRadiusInMeter: true,
                      radius: 10,
                    ),
                    CircleMarker(
                      point: LatLng(latitude, longitude),
                      color: const Color(0xff007AFF).withOpacity(0.4),
                      borderStrokeWidth: 0,
                      useRadiusInMeter: true,
                      radius: 70,
                    ),
                  ],
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: LatLng(endLatitude, endLongitude),
                      color: const Color(0xffCE534C),
                      borderColor: Colors.white,
                      borderStrokeWidth: 3,
                      useRadiusInMeter: true,
                      radius: 10,
                    ),
                  ],
                ),
                // MarkerLayer(
                //   markers: [
                //     buildEndPin(
                //       LatLng(endLatitude, endLongitude),
                //     ),
                //   ],
                // ),
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
                  fillColor: Colors.white.withOpacity(0.9),
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
            Positioned(
              bottom: 132,
              left: 15,
              child: FloatingActionButton(
                onPressed: () {
                  _animatedMapMove(latitude, longitude, 16.5);
                  setState(() {
                    checkCar = true;
                    checkBicycle = false;
                    checkFoot = false;
                  });
                  getRoute();
                },
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                child: SvgPicture.asset(
                  'assets/icons/car.svg',
                  colorFilter: ColorFilter.mode(
                    checkCar ? const Color(0xff007AFF) : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 132,
              left: 125,
              child: FloatingActionButton(
                onPressed: () {
                  _animatedMapMove(latitude, longitude, 16.5);
                  setState(() {
                    checkCar = false;
                    checkBicycle = true;
                    checkFoot = false;
                  });
                  getRoute();
                },
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                child: SvgPicture.asset(
                  'assets/icons/bicycle.svg',
                  colorFilter: ColorFilter.mode(
                    checkBicycle ? const Color(0xff007AFF) : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 132,
              left: 245,
              child: FloatingActionButton(
                onPressed: () {
                  _animatedMapMove(latitude, longitude, 16.5);
                  setState(() {
                    checkCar = false;
                    checkBicycle = false;
                    checkFoot = true;
                  });
                  getRoute();

// 45
// 135
// 225
// 330

                  // final lat = 16.845258; // Example latitude
                  // final lng = 96.132772; // Example longitude
                  // final brng = 225.0; // Example bearing in degrees
                  // final distance = 330.1; // Example distance in meters

                  // final result = reverseCalc(lat, lng, brng, distance);
                  // print(result);
                },
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                child: SvgPicture.asset(
                  'assets/icons/foot.svg',
                  colorFilter: ColorFilter.mode(
                    checkFoot ? const Color(0xff007AFF) : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 15,
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 75,
                width: 290,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Distance",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          metersToKilometers(distance),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Duration",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          secondsToHoursMinutesSeconds(duration),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
