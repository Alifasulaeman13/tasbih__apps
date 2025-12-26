import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_times.dart';
import '../services/prayer_service.dart';
import 'dart:async';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerService _prayerService = PrayerService();
  late PrayerTimes _prayerTimes;
  Timer? _timer;

  Map<PrayerType, bool> _alarmStatus = {};

  @override
  void initState() {
    super.initState();
    _prayerTimes = _prayerService.calculatePrayerTimes();
    _loadAlarmStatus();

    // Update countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadAlarmStatus() async {
    final fajrEnabled = await _prayerService.isPrayerAlarmEnabled(
      PrayerType.fajr,
    );
    final dhuhrEnabled = await _prayerService.isPrayerAlarmEnabled(
      PrayerType.dhuhr,
    );
    final asrEnabled = await _prayerService.isPrayerAlarmEnabled(
      PrayerType.asr,
    );
    final maghribEnabled = await _prayerService.isPrayerAlarmEnabled(
      PrayerType.maghrib,
    );
    final ishaEnabled = await _prayerService.isPrayerAlarmEnabled(
      PrayerType.isha,
    );

    setState(() {
      _alarmStatus = {
        PrayerType.fajr: fajrEnabled,
        PrayerType.dhuhr: dhuhrEnabled,
        PrayerType.asr: asrEnabled,
        PrayerType.maghrib: maghribEnabled,
        PrayerType.isha: ishaEnabled,
      };
    });
  }

  Future<void> _toggleAlarm(PrayerType type, bool value) async {
    await _prayerService.togglePrayerAlarm(type, value);
    setState(() {
      _alarmStatus[type] = value;
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _getCountdownToNextPrayer() {
    final nextPrayer = _prayerTimes.getNextPrayer();
    final nextTime = nextPrayer['time'] as DateTime;
    final now = DateTime.now();
    final difference = nextTime.difference(now);

    if (difference.isNegative) {
      return '';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = _prayerTimes.getNextPrayer();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/islamic_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1F4C6B).withOpacity(0.9),
                const Color(0xFF1F4C6B).withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: const Text(
                    'Waktu Sholat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),

                // Next Prayer Countdown Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Sholat Selanjutnya',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nextPrayer['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getCountdownToNextPrayer(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(nextPrayer['time']),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                // Location Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Bogor Barat, WIB',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Prayer Times List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPrayerTimeCard(
                        'Subuh',
                        _prayerTimes.fajr,
                        PrayerType.fajr,
                        Icons.nightlight_round,
                      ),
                      const SizedBox(height: 12),
                      _buildPrayerTimeCard(
                        'Dzuhur',
                        _prayerTimes.dhuhr,
                        PrayerType.dhuhr,
                        Icons.wb_sunny,
                      ),
                      const SizedBox(height: 12),
                      _buildPrayerTimeCard(
                        'Ashar',
                        _prayerTimes.asr,
                        PrayerType.asr,
                        Icons.wb_twilight,
                      ),
                      const SizedBox(height: 12),
                      _buildPrayerTimeCard(
                        'Maghrib',
                        _prayerTimes.maghrib,
                        PrayerType.maghrib,
                        Icons.wb_twilight,
                      ),
                      const SizedBox(height: 12),
                      _buildPrayerTimeCard(
                        'Isya',
                        _prayerTimes.isha,
                        PrayerType.isha,
                        Icons.nights_stay,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(
    String name,
    DateTime time,
    PrayerType type,
    IconData icon,
  ) {
    final hasPassed = _prayerTimes.hasPassed(type);
    final isAlarmEnabled = _alarmStatus[type] ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            hasPassed
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              hasPassed
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: hasPassed ? Colors.white38 : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: hasPassed ? Colors.white38 : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatTime(time),
                  style: TextStyle(
                    color: hasPassed ? Colors.white24 : Colors.white70,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isAlarmEnabled,
            onChanged: (value) => _toggleAlarm(type, value),
            activeColor: Colors.green,
            inactiveThumbColor: Colors.white38,
          ),
        ],
      ),
    );
  }
}
