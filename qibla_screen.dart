import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_colors.dart';
import '../services/prayer_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  // কাবা শরীফের অবস্থান (মক্কা)
  static const double _kaabaLat = 21.4225;
  static const double _kaabaLng = 39.8262;

  double? _qiblaBearing; // উত্তর থেকে কিবলার দিক (ডিগ্রি)
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<CompassEvent>? _compassSub;
  double? _heading; // ফোন এখন কোন দিকে তাক করা আছে

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final position = await PrayerService.getCurrentLocation();
      final bearing = _calculateQiblaBearing(
        position.latitude,
        position.longitude,
      );
      setState(() {
        _qiblaBearing = bearing;
        _isLoading = false;
      });

      if (FlutterCompass.events == null) {
        setState(() {
          _errorMessage = 'এই ডিভাইসে কম্পাস সেন্সর পাওয়া যায়নি।';
        });
        return;
      }

      _compassSub = FlutterCompass.events!.listen((event) {
        if (mounted && event.heading != null) {
          setState(() => _heading = event.heading);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _friendlyError(e.toString());
      });
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('LOCATION_SERVICE_DISABLED')) {
      return 'ফোনের লোকেশন সার্ভিস বন্ধ আছে। সেটিংস থেকে লোকেশন চালু করুন।';
    }
    if (raw.contains('LOCATION_PERMISSION')) {
      return 'লোকেশন পারমিশন ছাড়া কিবলার দিক বের করা যাবে না। পারমিশন দিন।';
    }
    return 'কিবলার দিক বের করা যায়নি। আবার চেষ্টা করুন।';
  }

  /// দুইটা geographic coordinate থেকে কিবলার bearing (উত্তর থেকে ডিগ্রি) হিসাব করে
  double _calculateQiblaBearing(double lat, double lng) {
    final lat1 = lat * math.pi / 180;
    final lat2 = _kaabaLat * math.pi / 180;
    final deltaLng = (_kaabaLng - lng) * math.pi / 180;

    final y = math.sin(deltaLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      color: AppColors.emeraldDeep,
      child: const Text(
        'কিবলার দিক',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.emeraldMid),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 32),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _init,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldMid),
                child: const Text('আবার চেষ্টা করুন', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_heading == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'কম্পাস সেন্সর থেকে ডেটা আসার অপেক্ষায়...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
      );
    }

    // কিবলার দিক ও ফোনের বর্তমান দিকের মধ্যে পার্থক্য বের করে ঘুরানোর জন্য
    final rotation = ((_qiblaBearing ?? 0) - _heading!) * (math.pi / 180);
    final isAligned = _angleDiff(_qiblaBearing ?? 0, _heading!) < 5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isAligned ? 'কিবলামুখী! 🕋' : 'ফোনটা ঘুরিয়ে তীরটাকে উপরে নিয়ে আসুন',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isAligned ? AppColors.emeraldMid : AppColors.muted,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isAligned ? AppColors.emeraldMid : AppColors.gold,
                    width: 3,
                  ),
                ),
              ),
              Transform.rotate(
                angle: rotation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.navigation,
                      size: 90,
                      color: AppColors.emeraldDeep,
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 14,
                child: Text(
                  'N',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'কিবলা: ${(_qiblaBearing ?? 0).toStringAsFixed(0)}° (উত্তর থেকে)',
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
        ),
      ],
    );
  }

  double _angleDiff(double a, double b) {
    final diff = (a - b).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }
}
