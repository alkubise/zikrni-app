import 'package:flutter/material.dart';

class LocalizationService {
  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'app_title': 'أذكار',
      'qibla': 'اتجاه القبلة',
      'morning_azkar': 'أذكار الصباح',
      'evening_azkar': 'أذكار المساء',
      'location_rationale_title': 'الوصول للموقع',
      'location_rationale_desc': 'نحتاج للوصول إلى موقعك الجغرافي لنتمكن من تحديد اتجاه القبلة بدقة وحساب مواقيت الصلاة الصحيحة لمدينتك.',
      'ok': 'موافق',
      'retry': 'إعادة المحاولة',
      'loading_qibla': 'جارٍ تحديد اتجاه القبلة...',
      'reading_compass': 'جارٍ قراءة البوصلة...',
      'qibla_error': 'يرجى تشغيل خدمة الموقع أولاً',
      'permission_error': 'صلاحية الموقع مطلوبة لتحديد اتجاه القبلة',
      'generic_error': 'حدث خطأ ما',
      'kaaba': 'الكعبة',
      'point_phone': 'وجّه أعلى الهاتف نحو السهم',
      'rain_dua': 'اللهم صيباً نافعاً',
      'travel_dua': 'سبحان الذي سخر لنا هذا وما كنا له مقرنين',
    },
    'en': {
      'app_title': 'Azkar',
      'qibla': 'Qibla Direction',
      'morning_azkar': 'Morning Azkar',
      'evening_azkar': 'Evening Azkar',
      'location_rationale_title': 'Location Access',
      'location_rationale_desc': 'We need access to your location to accurately determine the Qibla direction and calculate the correct prayer times for your city.',
      'ok': 'OK',
      'retry': 'Retry',
      'loading_qibla': 'Determining Qibla direction...',
      'reading_compass': 'Reading compass...',
      'qibla_error': 'Please enable location services first',
      'permission_error': 'Location permission is required for Qibla direction',
      'generic_error': 'Something went wrong',
      'kaaba': 'Kaaba',
      'point_phone': 'Point the top of your phone towards the arrow',
      'rain_dua': 'O Allah, may it be a beneficial rain',
      'travel_dua': 'Glory to Him Who has brought this under our control',
    },
    'ur': { // Urdu
      'app_title': 'اذکار',
      'qibla': 'قبلہ کی سمت',
      'morning_azkar': 'صبح کے اذکار',
      'evening_azkar': 'شام کے اذکار',
      'ok': 'ٹھیک ہے',
      'kaaba': 'کعبہ',
      'rain_dua': 'اے اللہ، اسے فائدہ مند بارش بنا',
    },
    'id': { // Indonesian
      'app_title': 'Azkar',
      'qibla': 'Arah Kiblat',
      'morning_azkar': 'Dzikir Pagi',
      'evening_azkar': 'Dzikir Petang',
      'ok': 'OK',
      'kaaba': 'Ka\'bah',
      'rain_dua': 'Ya Allah, jadikanlah hujan ini bermanfaat',
    },
    'tr': { // Turkish
      'app_title': 'Zikirler',
      'qibla': 'Kıble Yönü',
      'morning_azkar': 'Sabah Zikirleri',
      'evening_azkar': 'Akşam Zikirleri',
      'ok': 'Tamam',
      'kaaba': 'Kabe',
      'rain_dua': 'Allah\'ım, bu yağmuru yararlı kıl',
    },
    'fr': { // French
      'app_title': 'Azkar',
      'qibla': 'Direction de la Qibla',
      'morning_azkar': 'Azkar du Matin',
      'evening_azkar': 'Azkar du Soir',
      'ok': 'OK',
      'kaaba': 'Kaaba',
      'rain_dua': 'Ô Allah, fasse que cette pluie soit bénéfique',
    },
  };

  static String translate(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    final Map<String, String> translations = _localizedValues[locale] ?? _localizedValues['ar']!;
    return translations[key] ?? _localizedValues['ar']![key]!;
  }
}
