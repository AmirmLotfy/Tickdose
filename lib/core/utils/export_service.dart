import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:tickdose/core/services/provider_analytics_service.dart';
import 'package:tickdose/core/utils/logger.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

/// Service for exporting analytics data in various formats
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  /// Export analytics to PDF
  Future<String> exportAnalytics(ExportData exportData, {String format = 'pdf'}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'patient_analytics_$timestamp.$format';
      final filePath = '${directory.path}/$fileName';

      if (format == 'pdf') {
        return await _exportToPDF(exportData, filePath);
      } else if (format == 'csv') {
        return await _exportToCSV(exportData, filePath);
      } else {
        throw Exception('Unsupported format: $format');
      }
    } catch (e) {
      Logger.error('Error exporting analytics: $e', tag: 'ExportService');
      rethrow;
    }
  }

  Future<String> _exportToPDF(ExportData exportData, String filePath) async {
    final pdf = pw.Document();
    final analytics = exportData.analytics;
    final dateFormat = DateFormat('MMMM dd, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'Patient Medication Analytics Report',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),

            // Date range
            pw.Text(
              'Period: ${dateFormat.format(analytics.period.start)} - ${dateFormat.format(analytics.period.end)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),

            // Adherence overview
            pw.Header(
              level: 1,
              child: pw.Text('Adherence Overview'),
            ),
            pw.Table(
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Overall Adherence Rate'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${analytics.adherenceRate.toStringAsFixed(1)}%'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Total Doses'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${analytics.totalDoses}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Taken'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${analytics.takenDoses}'),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('Skipped'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${analytics.skippedDoses}'),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Medication Effectiveness
            pw.Header(
              level: 1,
              child: pw.Text('Medication Effectiveness'),
            ),
            ...analytics.effectivenessMetrics.values.map((metric) {
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      metric.medicineName,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Effectiveness Score: ${metric.effectivenessScore.toStringAsFixed(1)}/100'),
                    pw.Text('Adherence Rate: ${metric.adherenceRate.toStringAsFixed(1)}%'),
                    pw.Text('Side Effects: ${metric.sideEffectCount}'),
                  ],
                ),
              );
            }),
            pw.SizedBox(height: 20),

            // Side Effect Correlations
            if (analytics.sideEffectCorrelations.isNotEmpty) ...[
              pw.Header(
                level: 1,
                child: pw.Text('Side Effect Correlations'),
              ),
              ...analytics.sideEffectCorrelations.values.map((correlation) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        correlation.medicineName,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Side Effect: ${correlation.sideEffectType}'),
                      pw.Text('Correlation: ${correlation.correlationStrength}'),
                      pw.Text('Adherence: ${correlation.adherenceRate.toStringAsFixed(1)}%'),
                    ],
                  ),
                );
              }),
            ],
          ];
        },
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    Logger.info('PDF exported to: $filePath', tag: 'ExportService');
    return filePath;
  }

  Future<String> _exportToCSV(ExportData exportData, String filePath) async {
    final analytics = exportData.analytics;
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Patient Medication Analytics Report');
    buffer.writeln('Period: ${DateFormat('yyyy-MM-dd').format(analytics.period.start)} - ${DateFormat('yyyy-MM-dd').format(analytics.period.end)}');
    buffer.writeln();

    // Adherence overview
    buffer.writeln('Adherence Overview');
    buffer.writeln('Overall Rate,${analytics.adherenceRate.toStringAsFixed(1)}%');
    buffer.writeln('Total Doses,${analytics.totalDoses}');
    buffer.writeln('Taken,${analytics.takenDoses}');
    buffer.writeln('Skipped,${analytics.skippedDoses}');
    buffer.writeln();

    // Medication Effectiveness
    buffer.writeln('Medication Effectiveness');
    buffer.writeln('Medicine,Effectiveness Score,Adherence Rate,Side Effects');
    for (final metric in analytics.effectivenessMetrics.values) {
      buffer.writeln('${metric.medicineName},${metric.effectivenessScore.toStringAsFixed(1)},${metric.adherenceRate.toStringAsFixed(1)}%,${metric.sideEffectCount}');
    }
    buffer.writeln();

    // Side Effect Correlations
    if (analytics.sideEffectCorrelations.isNotEmpty) {
      buffer.writeln('Side Effect Correlations');
      buffer.writeln('Medicine,Side Effect,Correlation Strength,Adherence Rate');
      for (final correlation in analytics.sideEffectCorrelations.values) {
        buffer.writeln('${correlation.medicineName},${correlation.sideEffectType},${correlation.correlationStrength},${correlation.adherenceRate.toStringAsFixed(1)}%');
      }
    }

    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    Logger.info('CSV exported to: $filePath', tag: 'ExportService');
    return filePath;
  }
}
