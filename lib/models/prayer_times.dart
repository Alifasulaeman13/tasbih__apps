class PrayerTimes {
  final DateTime fajr;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime sunrise;

  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunrise,
  });

  /// Get prayer name for a specific time
  String getPrayerName(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return 'Subuh';
      case PrayerType.dhuhr:
        return 'Dzuhur';
      case PrayerType.asr:
        return 'Ashar';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isha:
        return 'Isya';
      case PrayerType.sunrise:
        return 'Sunrise';
    }
  }

  /// Get time for a specific prayer
  DateTime getTime(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return fajr;
      case PrayerType.dhuhr:
        return dhuhr;
      case PrayerType.asr:
        return asr;
      case PrayerType.maghrib:
        return maghrib;
      case PrayerType.isha:
        return isha;
      case PrayerType.sunrise:
        return sunrise;
    }
  }

  /// Get next prayer from current time
  Map<String, dynamic> getNextPrayer() {
    final now = DateTime.now();
    final prayers = [
      {'type': PrayerType.fajr, 'time': fajr, 'name': 'Subuh'},
      {'type': PrayerType.sunrise, 'time': sunrise, 'name': 'Sunrise'},
      {'type': PrayerType.dhuhr, 'time': dhuhr, 'name': 'Dzuhur'},
      {'type': PrayerType.asr, 'time': asr, 'name': 'Ashar'},
      {'type': PrayerType.maghrib, 'time': maghrib, 'name': 'Maghrib'},
      {'type': PrayerType.isha, 'time': isha, 'name': 'Isya'},
    ];

    for (var prayer in prayers) {
      if ((prayer['time'] as DateTime).isAfter(now)) {
        return prayer;
      }
    }

    // If all prayers have passed, return Fajr for tomorrow
    return {
      'type': PrayerType.fajr,
      'time': fajr.add(const Duration(days: 1)),
      'name': 'Subuh',
    };
  }

  /// Check if a prayer time has passed
  bool hasPassed(PrayerType type) {
    return getTime(type).isBefore(DateTime.now());
  }
}

enum PrayerType { fajr, sunrise, dhuhr, asr, maghrib, isha }
