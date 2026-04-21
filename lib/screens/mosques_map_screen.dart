import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../services/theme_service.dart';

class MosquesMapScreen extends StatefulWidget {
  const MosquesMapScreen({super.key});

  @override
  State<MosquesMapScreen> createState() => _MosquesMapScreenState();
}

class _MosquesMapScreenState extends State<MosquesMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
      _searchNearbyMosques(position.latitude, position.longitude);
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _searchNearbyMosques(double lat, double lon) async {
    // استخدام Overpass API (مجاني ولا يتطلب مفتاح) لجلب المساجد
    final url = 'https://overpass-api.de/api/interpreter?data=[out:json];node["amenity"="place_of_worship"]["religion"="muslim"](around:5000,$lat,$lon);out;';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List elements = data['elements'];
        
        setState(() {
          for (var element in elements) {
            final marker = Marker(
              markerId: MarkerId(element['id'].toString()),
              position: LatLng(element['lat'], element['lon']),
              infoWindow: InfoWindow(
                title: element['tags']['name'] ?? 'مسجد',
                snippet: 'مسجد قريب',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            );
            _markers.add(marker);
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching mosques: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  style: _darkMapStyle,
                ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37)),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "المساجد القريبة",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Cairo",
                          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          if (_loading)
             const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        ],
      ),
    );
  }

  // ستايل الخريطة الداكن ليتناسب مع التطبيق
  final String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#181818"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#000000"}]
  }
]
''';
}
