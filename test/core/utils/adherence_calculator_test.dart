import 'package:flutter_test/flutter_test.dart';
import 'package:tickdose/core/utils/adherence_calculator.dart';

void main() {
  group('AdherenceCalculator', () {
    test('calculateAdherence should return 100% for all taken', () {
      const taken = 10;
      const total = 10;
      
      final adherence = AdherenceCalculator.calculateAdherence(taken, total);
      expect(adherence, 100.0);
    });
    
    test('calculateAdherence should return 0% for none taken', () {
      const taken = 0;
      const total = 10;
      
      final adherence = AdherenceCalculator.calculateAdherence(taken, total);
      expect(adherence, 0.0);
    });
    
    test('calculateAdherence should calculate correctly for partial adherence', () {
      const taken = 7;
      const total = 10;
      
      final adherence = AdherenceCalculator.calculateAdherence(taken, total);
      expect(adherence, 70.0); // 7/10 * 100
    });
    
    test('calculateAdherence should handle zero total', () {
      const taken = 0;
      const total = 0;
      
      final adherence = AdherenceCalculator.calculateAdherence(taken, total);
      expect(adherence, 0.0);
    });
    
    test('getAdherenceStatus should return correct status', () {
      expect(AdherenceCalculator.getAdherenceStatus(95.0), 'Excellent');
      expect(AdherenceCalculator.getAdherenceStatus(80.0), 'Good');
      expect(AdherenceCalculator.getAdherenceStatus(60.0), 'Fair');
      expect(AdherenceCalculator.getAdherenceStatus(30.0), 'Needs Improvement');
    });
  });
}
