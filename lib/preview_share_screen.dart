import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class PreviewShareScreen extends StatelessWidget {
  final Map<String, String> data;

  const PreviewShareScreen({super.key, required this.data});

  /// Builds the PDF document using data
  pw.Document buildPdf() {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "SUIE JAMES",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text("House No. 10/1884, Kurisingal House"),
              pw.Text("ESI Road, Palluruthy, Cochin."),
              pw.Text("PAN: BAMPJ4570K"),
              pw.SizedBox(height: 10),
              pw.Text("SUIE JAMES | A/c: 1515100029173"),
              pw.Text("HDFC Bank, Palluruthy Br. | IFSC: HDFC0001515"),
              pw.Text("Mobile: 09847847774, 09554487774"),
              pw.Divider(),

              pw.Text(
                "Sl. No: ${data['Sl. No'] ?? ''}     Date: ${data['Date'] ?? ''}     Truck No: ${data['Truck No'] ?? ''}",
              ),
              pw.SizedBox(height: 10),
              pw.Text("To: ${data['To'] ?? ''}"),
              pw.SizedBox(height: 10),

              pw.Center(
                child: pw.Text(
                  "CONTAINER DETAILS",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),

              ...[
                'Container No',
                'Unloading Charge',
                '20/40 Axle',
                'Destination',
                'Hire',
                'Toll',
                'W. Charge',
                'Halting Charge',
                'Advance',
                'Total Amount',
              ].map(
                (field) => pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text("$field:")),
                    pw.Expanded(flex: 5, child: pw.Text(data[field] ?? '')),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Text("Driver Name: ${data['Driver Name'] ?? ''}"),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("SUIE JAMES"),
              ),
              pw.SizedBox(height: 30),
              pw.Text("Signature ____________________"),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Saves the PDF to temporary file and returns the File
  Future<File> savePdfToFile() async {
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/invoice_preview.pdf");
    final pdf = buildPdf();
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Shares the PDF file
  Future<void> sharePdf() async {
    final file = await savePdfToFile();
    await Share.shareXFiles([XFile(file.path)], text: "Invoice PDF");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview & Share")),
      body: Column(
        children: [
          Expanded(
            child: PdfPreview(
              build: (format) => buildPdf().save(),
              allowPrinting: false,
              allowSharing: false,
              canChangeOrientation: false,
              canChangePageFormat: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: sharePdf,
              icon: const Icon(Icons.share),
              label: const Text("Share via WhatsApp"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
