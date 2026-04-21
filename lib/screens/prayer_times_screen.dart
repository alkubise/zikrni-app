import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart' as intl;

import '../constants/app_colors.dart';
import 'widgets/premium_page_shell.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  bool _loading = true;
  String? _error;
  PrayerTimes? _prayerTimes;
  Timer? _timer;
  String _timeLeft = "";

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_prayerTimes != null) {
        _updateTimeLeft();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrayerTimes() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _loading = false;
          _error = "يرجى تشغيل خدمة الموقع";
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _loading = false;
          _error = "صلاحية الموقع مرفوضة";
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _loading = false;
          _error = "صلاحية الموقع مرفوضة نهائيًا";
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.karachi.getParameters()
        ..madhab = Madhab.shafi;

      final date = DateComponents.from(DateTime.now());
      final prayerTimes = PrayerTimes(coordinates, date, params);

      setState(() {
        _prayerTimes = prayerTimes;
        _loading = false;
      });

      _updateTimeLeft();
    } catch (_) {
      setState(() {
        _loading = false;
        _error = "فشل في جلب المواقيت";
      });
    }
  }

  void _updateTimeLeft() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final next = _prayerTimes!.nextPrayer();
    final nextTime = _prayerTimes!.timeForPrayer(next);

    if (nextTime != null) {
      final diff = nextTime.difference(now);
      if (diff.isNegative) {
        if (mounted) {
          setState(() => _timeLeft = "--:--:--");
        }
      } else {
        String twoDigits(int n) => n.toString().padLeft(2, "0");
        final h = twoDigits(diff.inHours);
        final m = twoDigits(diff.inMinutes.remainder(60));
        final s = twoDigits(diff.inSeconds.remainder(60));
        if (mounted) {
          setState(() => _timeLeft = "$h:$m:$s");
        }
      }
    }
  }

  String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return "الفجر";
      case Prayer.sunrise:
        return "الشروق";
      case Prayer.dhuhr:
        return "الظهر";
      case Prayer.asr:
        return "العصر";
      case Prayer.maghrib:
        return "المغرب";
      case Prayer.isha:
        return "العشاء";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return PremiumPageShell(
      title: "مواقيت الصلاة",
      topLabel: "PRAYER TIMES",
      goHomeOnBack: false,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    if (_error != null) {
      return Center(
        child: PremiumGlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: "Cairo",
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _fetchPrayerTimes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                ),
                child: const Text("إعادة المحاولة"),
              ),
            ],
          ),
        ),
      );
    }

    final nextPrayer = _prayerTimes!.nextPrayer();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _buildNextPrayerCard(nextPrayer),
        const SizedBox(height: 24),
        const PremiumSectionTitle("مواقيت اليوم"),
        const SizedBox(height: 16),
        _buildPrayerTimeRow(Prayer.fajr),
        _buildPrayerTimeRow(Prayer.sunrise),
        _buildPrayerTimeRow(Prayer.dhuhr),
        _buildPrayerTimeRow(Prayer.asr),
        _buildPrayerTimeRow(Prayer.maghrib),
        _buildPrayerTimeRow(Prayer.isha),
      ],
    );
  }

  Widget _buildNextPrayerCard(Prayer next) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            "الصلاة القادمة",
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 14,
              fontFamily: "Cairo",
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPrayerName(next),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontFamily: "Cairo",
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _timeLeft,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 42,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "الوقت المتبقي",
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 12,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeRow(Prayer prayer) {
    final time = _prayerTimes!.timeForPrayer(prayer);
    final formattedTime = intl.DateFormat.jm().format(time!);
    final isNext = _prayerTimes!.nextPrayer() == prayer;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: PremiumGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isNext
                        ? AppColors.gold.withOpacity(0.14)
                        : Colors.white.withOpacity(0.04),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: isNext ? AppColors.gold : Colors.white54,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getPrayerName(prayer),
                  style: TextStyle(
                    color: isNext ? AppColors.gold : Colors.white,
                    fontSize: 17,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                    fontFamily: "Cairo",
                  ),
                ),
              ],
            ),
            Text(
              formattedTime,
              style: TextStyle(
                color: isNext ? AppColors.gold : Colors.white70,
                fontSize: 17,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}