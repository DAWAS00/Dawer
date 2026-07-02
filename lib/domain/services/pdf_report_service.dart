import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../entities/earnings/earnings_summary.dart';

class PdfReportService {
  Future<void> generateAndShareReport(EarningsSummary summary) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Rider Earnings Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Performance Summary'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Earnings:'),
                  pw.Text('${summary.totalEarnings.toStringAsFixed(2)} JD'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Distance:'),
                  pw.Text('${summary.totalDistance.toStringAsFixed(1)} KM'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Trips:'),
                  pw.Text('${summary.totalTrips}'),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Detailed Analysis'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Average Earnings per Trip: ${summary.averageEarningsPerTrip.toStringAsFixed(2)} JD',
              ),
              pw.Text(
                'Average Earnings per KM: ${summary.averageEarningsPerKm.toStringAsFixed(2)} JD',
              ),
              pw.SizedBox(height: 30),
              pw.Text('Recent Activity'),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Order ID', 'Date', 'Amount', 'Distance'],
                  ...summary.recentTrips.map(
                    (t) => [
                      t.orderId,
                      t.date.toString().split(' ')[0],
                      '${t.amount} JD',
                      '${t.distanceKm} KM',
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/earnings_report.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Earnings Report');
  }
}
