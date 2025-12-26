import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times.dart' as models;
import 'notification_service.dart';

class PrayerService {
  static final PrayerService _instance = PrayerService._internal();
  factory PrayerService() => _instance;
  PrayerService._internal();

  final NotificationService _notificationService = NotificationService();

  // Bogor Barat coordinates
  static const double _latitude = -6.5950;
  static const double _longitude = 106.7970;

  // Notification IDs for each prayer
  static const int _fajrNotificationId = 100;
  static const int _dhuhrNotificationId = 101;
  static const int _asrNotificationId = 102;
  static const int _maghribNotificationId = 103;
  static const int _ishaNotificationId = 104;

  /// Calculate today's prayer times for Bogor Barat
  models.PrayerTimes calculatePrayerTimes() {
    final coordinates = Coordinates(_latitude, _longitude);
    final date = DateComponents.from(DateTime.now());

    // Use calculation parameters for Indonesia (similar to Kemenag)
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;

    final prayerTimes = PrayerTimes(coordinates, date, params);

    return models.PrayerTimes(
      fajr: prayerTimes.fajr,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      sunrise: prayerTimes.sunrise,
    );
  }

  /// Schedule all prayer notifications for today
  Future<void> scheduleAllPrayerNotifications() async {
    final prayerTimes = calculatePrayerTimes();
    final prefs = await SharedPreferences.getInstance();

    // Check if each prayer alarm is enabled
    final fajrEnabled = prefs.getBool('alarm_fajr') ?? true;
    final dhuhrEnabled = prefs.getBool('alarm_dhuhr') ?? true;
    final asrEnabled = prefs.getBool('alarm_asr') ?? true;
    final maghribEnabled = prefs.getBool('alarm_maghrib') ?? true;
    final ishaEnabled = prefs.getBool('alarm_isha') ?? true;

    // Schedule notifications for enabled prayers
    if (fajrEnabled) {
      await _notificationService.schedulePrayerNotification(
        id: _fajrNotificationId,
        prayerName: 'Subuh',
        scheduledTime: prayerTimes.fajr,
      );
    }

    if (dhuhrEnabled) {
      await _notificationService.schedulePrayerNotification(
        id: _dhuhrNotificationId,
        prayerName: 'Dzuhur',
        scheduledTime: prayerTimes.dhuhr,
      );
    }

    if (asrEnabled) {
      await _notificationService.schedulePrayerNotification(
        id: _asrNotificationId,
        prayerName: 'Ashar',
        scheduledTime: prayerTimes.asr,
      );
    }

    if (maghribEnabled) {
      await _notificationService.schedulePrayerNotification(
        id: _maghribNotificationId,
        prayerName: 'Maghrib',
        scheduledTime: prayerTimes.maghrib,
      );
    }

    if (ishaEnabled) {
      await _notificationService.schedulePrayerNotification(
        id: _ishaNotificationId,
        prayerName: 'Isya',
        scheduledTime: prayerTimes.isha,
      );
    }
  }

  /// Toggle prayer alarm on/off
  Future<void> togglePrayerAlarm(models.PrayerType type, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    String key;
    int notificationId;

    switch (type) {
      case models.PrayerType.fajr:
        key = 'alarm_fajr';
        notificationId = _fajrNotificationId;
        break;
      case models.PrayerType.dhuhr:
        key = 'alarm_dhuhr';
        notificationId = _dhuhrNotificationId;
        break;
      case models.PrayerType.asr:
        key = 'alarm_asr';
        notificationId = _asrNotificationId;
        break;
      case models.PrayerType.maghrib:
        key = 'alarm_maghrib';
        notificationId = _maghribNotificationId;
        break;
      case models.PrayerType.isha:
        key = 'alarm_isha';
        notificationId = _ishaNotificationId;
        break;
      case models.PrayerType.sunrise:
        return; // Sunrise doesn't have alarm
    }

    await prefs.setBool(key, enabled);

    if (!enabled) {
      // Cancel the notification if disabled
      await _notificationService.cancelNotification(notificationId);
    } else {
      // Reschedule if enabled
      await scheduleAllPrayerNotifications();
    }
  }

  /// Get prayer alarm status
  Future<bool> isPrayerAlarmEnabled(models.PrayerType type) async {
    final prefs = await SharedPreferences.getInstance();
    String key;

    switch (type) {
      case models.PrayerType.fajr:
        key = 'alarm_fajr';
        break;
      case models.PrayerType.dhuhr:
        key = 'alarm_dhuhr';
        break;
      case models.PrayerType.asr:
        key = 'alarm_asr';
        break;
      case models.PrayerType.maghrib:
        key = 'alarm_maghrib';
        break;
      case models.PrayerType.isha:
        key = 'alarm_isha';
        break;
      case models.PrayerType.sunrise:
        return false; // Sunrise doesn't have alarm
    }

    return prefs.getBool(key) ?? true; // Default enabled
  }

  /// Initialize prayer service
  Future<void> initialize() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
    await scheduleAllPrayerNotifications();
  }
}
