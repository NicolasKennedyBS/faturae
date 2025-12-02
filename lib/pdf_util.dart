import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

enum ReceiptStyle { simple, modern }

class PdfUtil {

  static Future<void> generateAndShowReceipt({
    required String clientName,
    required String serviceDescription,
    required String value,
    required String date,
    required ReceiptStyle style,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          if (style == ReceiptStyle.modern) {
            return _buildModernLayout(clientName, serviceDescription, value, date);
          } else {
            return _buildSimpleLayout(clientName, serviceDescription, value, date);
          }
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Recibo_$clientName.pdf',
    );
  }

  static pw.Widget _buildSimpleLayout(String client, String service, String value, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 0,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("RECIBO", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
              pw.Text("Faturaê", style: const pw.TextStyle(color: PdfColors.grey)),
            ],
          ),
        ),
        pw.SizedBox(height: 30),
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text("R\$ $value", style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Divider(),
        pw.SizedBox(height: 20),
        pw.Text("Recebemos de: $client", style: const pw.TextStyle(fontSize: 18)),
        pw.SizedBox(height: 10),
        pw.Text("Referente a: $service", style: const pw.TextStyle(fontSize: 18)),
        pw.Spacer(),
        pw.Text("Data: $date"),
        pw.SizedBox(height: 10),
        pw.Divider(borderStyle: pw.BorderStyle.dashed),
        pw.Center(child: pw.Text("Assinatura do Prestador")),
      ],
    );
  }

  static pw.Widget _buildModernLayout(String client, String service, String value, String date) {
    return pw.Column(
      children: [
        pw.Container(
          color: PdfColors.blue900,
          padding: const pw.EdgeInsets.all(20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("RECIBO DE PAGAMENTO", style: pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Text("Faturaê", style: pw.TextStyle(color: PdfColors.white, fontSize: 12)),
            ],
          ),
        ),
        pw.SizedBox(height: 40),

        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blue900, width: 2),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: pw.Column(
            children: [
              pw.Text("VALOR TOTAL", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              pw.Text("R\$ $value", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            ],
          ),
        ),
        pw.SizedBox(height: 40),

        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          color: PdfColors.grey100,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("PAGADOR (CLIENTE)", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.Text(client, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ]),
        ),
        pw.SizedBox(height: 5),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          color: PdfColors.grey100,
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("DESCRIÇÃO DO SERVIÇO", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            pw.Text(service, style: const pw.TextStyle(fontSize: 16)),
          ]),
        ),

        pw.Spacer(),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text("EMITIDO EM", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text(date, style: const pw.TextStyle(fontSize: 14)),
            ]),
            pw.Column(children: [
              pw.Container(width: 150, height: 1, color: PdfColors.blue900),
              pw.SizedBox(height: 5),
              pw.Text("Assinatura Autorizada", style: pw.TextStyle(fontSize: 10, color: PdfColors.blue900)),
            ]),
          ],
        ),
        pw.SizedBox(height: 20),
      ],
    );
  }
}