class AdherenceCalculator {
  static double calculateAdherence(int taken, int total) {
    if (total == 0) return 0.0;
    return (taken / total) * 100;
  }

  static String getAdherenceStatus(double adherence) {
    if (adherence >= 90) return 'Excellent';
    if (adherence >= 75) return 'Good';
    if (adherence >= 50) return 'Fair';
    return 'Needs Improvement';
  }
}
