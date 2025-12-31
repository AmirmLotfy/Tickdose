import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tickdose/core/models/medicine_log_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<void> generateAndShareReport(List<MedicineLogModel> logs) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('TICKDOSE Adherence Report',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Date', 'Time', 'Medicine', 'Status'],
                  ...logs.map((log) => [
                        DateFormat('yyyy-MM-dd').format(log.takenAt),
                        DateFormat('HH:mm').format(log.takenAt),
                        log.medicineName,
                        log.status,
                      ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'tickdose_report.pdf');
  }
}
