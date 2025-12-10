import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'pdf_util.dart';

class PdfPreviewPage extends StatelessWidget {
  final String issuerName;
  final String pixKey;
  final String clientName;
  final String serviceDescription;
  final String value;
  final String date;
  final ReceiptStyle style;
  final bool isProduct;
  final String qty;
  final String unitPrice;

  const PdfPreviewPage({
    super.key,
    required this.issuerName,
    required this.pixKey,
    required this.clientName,
    required this.serviceDescription,
    required this.value,
    required this.date,
    required this.style,
    required this.isProduct,
    required this.qty,
    required this.unitPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visualizar Documento"),
        centerTitle: true,
      ),
      body: PdfPreview(
        canDebug: false,
        canChangeOrientation: false,
        canChangePageFormat: false,

        build: (format) => PdfUtil.generateBytes(
          issuerName: issuerName,
          pixKey: pixKey,
          clientName: clientName,
          serviceDescription: serviceDescription,
          value: value,
          date: date,
          style: style,
          isProduct: isProduct,
          qty: qty,
          unitPrice: unitPrice,
        ),
      ),
    );
  }
}