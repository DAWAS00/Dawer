import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../data/utils/platform_impact_stats.dart';

/// Generates a shareable PDF snapshot of the platform's current
/// environmental impact ("CO₂ certificate") and hands it to the OS share
/// sheet. No account or backend request needed — the certificate is built
/// entirely from live in-app data at the moment of download.
class Co2CertificatePdfService {
  Future<void> generateAndShareCertificate(
    PlatformImpactStats stats, {
    DateTime? generatedAt,
  }) async {
    final date = generatedAt ?? DateTime.now();
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
                  'Dwaar (دوّر) — CO2 Impact Certificate',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Generated: ${date.toIso8601String().split('T').first}'),
              pw.SizedBox(height: 20),
              pw.Text('Platform Impact To Date'),
              pw.Divider(),
              pw.SizedBox(height: 10),
              _row('Orders Completed', '${stats.totalOrders}'),
              _row('Total Weight Recycled', '${stats.totalWeightKg.toStringAsFixed(1)} kg'),
              _row('CO2 Saved', '${stats.co2SavedKg.toStringAsFixed(1)} kg'),
              _row('Water Saved', '${stats.waterSavedLiters.toStringAsFixed(0)} L'),
              _row('Energy Saved', '${stats.energySavedKwh.toStringAsFixed(1)} kWh'),
              pw.SizedBox(height: 24),
              pw.Text(
                'This certificate reflects a live snapshot of Dwaar\'s '
                'platform-wide recycling activity at the time of download.',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/dwaar_co2_certificate.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: 'Dwaar CO2 Impact Certificate');
  }

  pw.Widget _row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [pw.Text(label), pw.Text(value)],
        ),
      );
}
