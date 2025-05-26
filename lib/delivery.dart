import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const Color kCoffee = Color(0xFFC67C4E);
const double kRadius = 18;
const String kGoogleApiKey = 'YOUR_KEY'; // your api key
const String _mapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]
''';

/// Demo coordinates ---------------------------------------------------------
const LatLng kOrigin = LatLng(3.0738, 101.5884);      // SS 15, Subang Jaya
const LatLng kDestination = LatLng(3.0722, 101.6070); // sunway pyramid

class DeliveryTrackingPage extends StatefulWidget {
  const DeliveryTrackingPage({super.key});

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  List<LatLng> _route = [];

  @override
  void initState() {
    super.initState();
    _getRoute();        
  }

 String? _durationText;

  Future<void> _getRoute() async {
    final PolylinePoints polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      kGoogleApiKey,
      PointLatLng(kOrigin.latitude, kOrigin.longitude),
      PointLatLng(kDestination.latitude, kDestination.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      setState(() {
        _route = result.points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
      });
    } else {
      setState(() => _route = [kOrigin, kDestination]);
    }

    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${kOrigin.latitude},${kOrigin.longitude}&destination=${kDestination.latitude},${kDestination.longitude}&mode=driving&key=$kGoogleApiKey');

    final response = await Uri.base.resolveUri(uri).resolve('').toString();
    final data = await NetworkAssetBundle(Uri.parse(uri.toString()))
        .load(uri.toString());
    final jsonString = String.fromCharCodes(data.buffer.asUint8List());
    final jsonData = jsonDecode(jsonString);

    if (jsonData['routes'] != null &&
        jsonData['routes'].isNotEmpty &&
        jsonData['routes'][0]['legs'] != null) {
      setState(() {
        _durationText = jsonData['routes'][0]['legs'][0]['duration']['text'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ------------------- MAP ----------------------------------------
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: kOrigin,
              zoom: 14.5,
            ),
            polylines: _route.length < 2
              ? {}
              : {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    color: kCoffee,
                    width: 5,
                    points: _route,
                  ),
                },
            markers: {
              const Marker(
                markerId: MarkerId('store'),
                position: kOrigin,
                icon: BitmapDescriptor.defaultMarker,
              ),
              const Marker(
                markerId: MarkerId('destination'),
                position: kDestination,
              ),
            },
            myLocationEnabled: false,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              controller.setMapStyle(_mapStyle);

              final GoogleMapController map = await _controller.future;

              if (_route.length >= 2) {
                final bounds = LatLngBounds(
                  southwest: LatLng(
                    _route.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
                    _route.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
                  ),
                  northeast: LatLng(
                    _route.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
                    _route.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
                  ),
                );

                map.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
              }
            }
          ),

          // ------------------- TOP BAR (back + map-controls) --------------
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.black87, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),

          // ------------------- BOTTOM SHEET -------------------------------
          _TrackingBottomSheet(durationText: _durationText),
        ],
      ),
    );
  }
}

class _TrackingBottomSheet extends StatelessWidget {
  final String? durationText;
  const _TrackingBottomSheet({this.durationText});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                durationText ?? 'Calculating ETA...',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                  children: [
                    TextSpan(text: 'Delivery to '),
                    TextSpan(
                      text: '3, Jalan PJS 11/15',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: kCoffee),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _ProgressBar(),
              const SizedBox(height: 24),

              _StatusCard(),
              const SizedBox(height: 16),

              _CourierCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _segment(active: true),
        _segment(active: true),
        _segment(active: false),
      ],
    );
  }

  Expanded _segment({required bool active}) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? kCoffee : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: kCoffee.withOpacity(.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_shipping_rounded,
                color: kCoffee, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Delivered your order',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
    );
  }
}

class _CourierCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // avatar
        const CircleAvatar(
          radius: 26,
          backgroundImage: AssetImage('assets/mock/courier.jpg'),
        ),
        const SizedBox(width: 12),
        // name & role
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Brooklyn Simmons',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text('Personal Courier',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        // call button
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: kCoffee,
          ),
          child: IconButton(
            icon: const Icon(Icons.phone_outlined,
                color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
