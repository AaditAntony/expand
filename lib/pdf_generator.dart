import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> generateTransportBill({
  required String invoiceNumber,
  required String date,
  required String truckNumber,
  required String recipientName,
  required String containerNumber,
  required String unloadingCharge,
  required String axleType,
  required String destination,
  required String hireCharge,
  required String tollCharge,
  required String weighingCharge,
  required String haltingCharge,
  required String advanceAmount,
  required String driverName,
}) async {
  final pdf = pw.Document();
  final now = DateTime.now();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with business and bank info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Business Info (Left)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SUIE JAMES',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text('House No. 10/1884, Kurisingal House'),
                    pw.Text('ESI Road, Palluruthy, Cochin.'),
                    pw.Text('PAN: BAMPJ4570K'),
                  ],
                ),
                // Bank Info (Right)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // pw.Text(
                    //   'SUIE JAMES',
                    //   style: pw.TextStyle(
                    //     fontSize: 14,
                    //     fontWeight: pw.FontWeight.bold,
                    //   ),
                    // ),
                    pw.Text('A/c No: 1515100029173'),
                    pw.Text('HDFC Bank, Palluruthy Br.'),
                    pw.Text('IFSC code HDFC0001515'),
                    pw.Text('Mobile: 09847847774, 09554487774'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Invoice Metadata
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'SL.No',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Date',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Truck No.',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(invoiceNumber),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(date),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(truckNumber),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Recipient/Consignee
            pw.Text('To', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(recipientName),
            pw.SizedBox(height: 20),

            // Container Details
            pw.Center(
              child: pw.Text(
                'CONTAINER DETAILS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            // Container Details Table
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(3),
              },
              children: [
                _buildDetailRow('CONTAINER No.', containerNumber),
                _buildDetailRow('UNLOADING CHARGE', unloadingCharge),
                _buildDetailRow('20/40', axleType),
                _buildDetailRow('DESTINATION', destination),
                _buildDetailRow('HIRE', hireCharge),
                _buildDetailRow('TOLL', tollCharge),
                _buildDetailRow('W. CHARGE', weighingCharge),
                _buildDetailRow('HALTING CHARGE', haltingCharge),
                _buildDetailRow('ADVANCE', advanceAmount),
                _buildDetailRow(
                  'TOTAL AMOUNT',
                  _calculateTotal(
                    unloadingCharge,
                    hireCharge,
                    tollCharge,
                    weighingCharge,
                    haltingCharge,
                    advanceAmount,
                  ).toString(),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Footer with driver name and signature
            pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Driver Name (Left)
                  pw.Container(
                    width: 200,
                    height: 100,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Driver Name:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(driverName),
                      ],
                    ),
                  ),
                  // Signature (Right)
                  pw.Container(
                    width: 200,
                    height: 100,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'SUIE JAMES',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 70),

                        pw.Text('Signature'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File(
    '${output.path}/transport_bill_${now.millisecondsSinceEpoch}.pdf',
  );
  await file.writeAsBytes(await pdf.save());
  return file;
}

pw.TableRow _buildDetailRow(String label, String value) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ),
      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(value)),
    ],
  );
}

double _calculateTotal(
  String unloading,
  String hire,
  String toll,
  String weighing,
  String halting,
  String advance,
) {
  return (double.tryParse(unloading) ?? 0) +
      (double.tryParse(hire) ?? 0) +
      (double.tryParse(toll) ?? 0) +
      (double.tryParse(weighing) ?? 0) +
      (double.tryParse(halting) ?? 0) -
      (double.tryParse(advance) ?? 0);
}
