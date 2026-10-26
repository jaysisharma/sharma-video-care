import 'package:flutter_test/flutter_test.dart';
import 'package:sharma_video_care_mobile/data/estimator_data.dart';
import 'package:sharma_video_care_mobile/data/trade_in_data.dart';
import 'package:sharma_video_care_mobile/services/localization_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('SvcLocalization Tests', () {
    test('Defaults to English and translates known keys', () {
      expect(SvcLocalization.t('nav.home'), 'Home');
      expect(SvcLocalization.t('hero.brandName'), 'QuickySewa');
    });

    test('Switches to Nepali and translates properly', () {
      SvcLocalization.setLanguage('ne');
      expect(SvcLocalization.isNepali, true);
      expect(SvcLocalization.t('nav.home'), 'गृहपृष्ठ');
      expect(SvcLocalization.t('hero.brandName'), 'क्विकीसेवा');
      SvcLocalization.setLanguage('en');
    });
  });

  group('Estimator Data Tests', () {
    test('Contains standard device categories and symptoms', () {
      expect(kEstimatorDevices.isNotEmpty, true);
      final cameraDevice = kEstimatorDevices.firstWhere((d) => d.slug == 'camera');
      expect(cameraDevice.symptoms.isNotEmpty, true);
      expect(cameraDevice.symptoms.first.minPrice > 0, true);
      expect(cameraDevice.symptoms.first.warrantyDays, 90);
    });
  });

  group('Trade-In Valuation Tests', () {
    test('Calculates valuation with condition multipliers and accessories', () {
      final sonyA7iv = kTradeInEquipments.firstWhere((e) => e.id == 'cam-sony-a7iv');
      final result = calculateTradeInValuation(
        equipment: sonyA7iv,
        cosmeticId: 'mint',
        functionalId: 'flawless',
        shutterId: 'low',
        selectedAccessoryIds: ['box', 'charger'],
      );

      expect(result.minCash > 0, true);
      expect(result.maxCash >= result.minCash, true);
      expect(result.minCredit > result.minCash, true);
      expect(result.accessoriesBonus, 4500); // 2500 + 2000
    });
  });
}
