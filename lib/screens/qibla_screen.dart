import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import '../services/theme_service.dart';
import '../services/localization_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  LocationPermission? _permission;
  bool _serviceEnabled = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    var permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      _showRationaleDialog();
    } else {
      _prepare();
    }
  }

  void _showRationaleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          LocalizationService.translate(context, 'location_rationale_title'),
          textAlign: TextAlign.start,
          style: const TextStyle(color: Color(0xFFD4AF37), fontFamily: "Cairo"),
        ),
        content: Text(
          LocalizationService.translate(context, 'location_rationale_desc'),
          textAlign: TextAlign.start,
          style: const TextStyle(color: Colors.white, fontFamily: "Cairo"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _prepare();
            },
            child: Text(
              LocalizationService.translate(context, 'ok'),
              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _prepare() async {
    setState(() => _loading = true);
    try {
      _serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_serviceEnabled) {
        setState(() {
          _loading = false;
          _error = LocalizationService.translate(context, 'qibla_error');
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _permission = permission;
          _loading = false;
          _error = LocalizationService.translate(context, 'permission_error');
        });
        return;
      }

      setState(() {
        _permission = permission;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = LocalizationService.translate(context, 'generic_error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              theme.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFD4AF37),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            LocalizationService.translate(context, 'qibla'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Cairo",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          width: 330,
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.36),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.22),
                            ),
                          ),
                          child: _buildBody(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFFD4AF37)),
          const SizedBox(height: 18),
          Text(
            LocalizationService.translate(context, 'loading_qibla'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontFamily: "Cairo"),
          ),
        ],
      );
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off_rounded,
              color: Color(0xFFD4AF37), size: 56),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: "Cairo",
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _prepare,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
            ),
            child: Text(
              LocalizationService.translate(context, 'retry'),
              style: const TextStyle(color: Colors.black, fontFamily: "Cairo"),
            ),
          ),
        ],
      );
    }

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFFD4AF37)),
              const SizedBox(height: 18),
              Text(
                LocalizationService.translate(context, 'reading_compass'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: "Cairo"),
              ),
            ],
          );
        }

        final direction = snapshot.data!;
        final angle = direction.qiblah;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocalizationService.translate(context, 'point_phone'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: "Cairo",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: (angle * (math.pi / 180) * -1),
                    child: const Icon(
                      Icons.navigation_rounded,
                      size: 110,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  Positioned(
                    top: 18,
                    child: Text(
                      LocalizationService.translate(context, 'kaaba'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "${angle.toStringAsFixed(1)}°",
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: "Cairo",
              ),
            ),
          ],
        );
      },
    );
  }
}
