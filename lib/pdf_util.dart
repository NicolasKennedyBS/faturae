import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'pix_generator.dart';

enum ReceiptStyle {
  simple, modern, tech, premium, minimal,
  construction, creative, health, retro, corporate, danfe,
  prof_elegant, prof_bold, prof_nature, prof_architect, prof_neon
}

class PdfUtil {

  static Future<Uint8List> generateBytes({
    required String issuerName,
    required String pixKey,
    required String clientName,
    required String serviceDescription,
    required String value,
    required String date,
    required ReceiptStyle style,
    bool isProduct = false,
    String qty = '1',
    String unitPrice = '',
  }) async {
    final doc = pw.Document();

    String? pixPayload;
    if (pixKey.isNotEmpty) {
      try {
        final cleanValueString = value.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.').trim();
        final doubleAmount = double.tryParse(cleanValueString) ?? 0.0;
        if (doubleAmount > 0) {
          final pix = PixGenerator(
            pixKey: pixKey,
            merchantName: issuerName,
            merchantCity: 'SAO PAULO',
            amount: doubleAmount,
            txid: 'FATURAE${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
          );
          pixPayload = pix.getPayload();
        }
      } catch (e) { print("Erro Pix: $e"); }
    }

    doc.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final args = [issuerName, clientName, serviceDescription, value, date, pixPayload, isProduct, qty, unitPrice];

          switch (style) {
            case ReceiptStyle.danfe: return _buildDanfeLayout(issuerName, clientName, serviceDescription, value, date, pixPayload, isProduct, qty, unitPrice);
            case ReceiptStyle.simple: return _buildSimpleLayout(args);
            case ReceiptStyle.modern: return _buildModernLayout(args);
            case ReceiptStyle.tech: return _buildTechLayout(args);
            case ReceiptStyle.premium: return _buildPremiumLayout(args);
            case ReceiptStyle.minimal: return _buildMinimalLayout(args);
            case ReceiptStyle.construction: return _buildConstructionLayout(args);
            case ReceiptStyle.creative: return _buildCreativeLayout(args);
            case ReceiptStyle.health: return _buildHealthLayout(args);
            case ReceiptStyle.retro: return _buildRetroLayout(args);
            case ReceiptStyle.corporate: return _buildCorporateLayout(args);
            case ReceiptStyle.prof_elegant: return _buildProfElegant(args);
            case ReceiptStyle.prof_bold: return _buildProfBold(args);
            case ReceiptStyle.prof_nature: return _buildProfNature(args);
            case ReceiptStyle.prof_architect: return _buildProfArchitect(args);
            case ReceiptStyle.prof_neon: return _buildProfNeon(args);
            default: return _buildSimpleLayout(args);
          }
        },
      ),
    );

    return doc.save();
  }

  static Future<void> generateAndShare({
    required String issuerName,
    required String pixKey,
    required String clientName,
    required String serviceDescription,
    required String value,
    required String date,
    required ReceiptStyle style,
    bool isProduct = false,
    String qty = '1',
    String unitPrice = '',
  }) async {
    final bytes = await generateBytes(
        issuerName: issuerName, pixKey: pixKey, clientName: clientName,
        serviceDescription: serviceDescription, value: value, date: date,
        style: style, isProduct: isProduct, qty: qty, unitPrice: unitPrice
    );

    final fileName = 'Recibo_${clientName.replaceAll(" ", "_")}.pdf';

    if (kIsWeb) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } else {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/$fileName");
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Olá $clientName, segue seu documento.');
    }
  }

  static pw.Widget _buildSmartTable(
      bool isProduct, String desc, String qty, String unitPrice, String total,
      {PdfColor headerColor = PdfColors.grey300, PdfColor headerTextColor = PdfColors.black}) {

    return pw.Table.fromTextArray(
      headers: isProduct
          ? ['ITEM / DESCRIÇÃO', 'UN', 'QTD', 'UNIT', 'TOTAL']
          : ['DESCRIÇÃO DO SERVIÇO', 'VALOR TOTAL'],
      data: isProduct
          ? [[desc, 'UN', qty, unitPrice, total]]
          : [[desc, total]],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: headerTextColor, fontSize: 9),
      headerDecoration: pw.BoxDecoration(color: headerColor),
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellAlignments: isProduct
          ? {0: pw.Alignment.centerLeft, 1: pw.Alignment.center, 2: pw.Alignment.center, 3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight}
          : {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }

  static pw.Widget _buildPixArea(String? payload) {
    if (payload == null || payload.isEmpty) return pw.Container();
    return pw.Container(
        margin: const pw.EdgeInsets.only(top: 20),
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(5)),
        child: pw.Row(mainAxisSize: pw.MainAxisSize.min, children: [
          pw.BarcodeWidget(data: payload, barcode: pw.Barcode.qrCode(), width: 70, height: 70),
          pw.SizedBox(width: 10),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("PAGUE VIA PIX", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green700, fontSize: 10)),
            pw.SizedBox(height: 2),
            pw.Text("Leia o QR Code com o app do banco", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text("Copia e Cola:", style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey)),
            pw.Container(width: 120, child: pw.Text(payload, maxLines: 2, style: const pw.TextStyle(fontSize: 5, color: PdfColors.grey500)))
          ])
        ])
    );
  }


  // 1. SIMPLES
  static pw.Widget _buildSimpleLayout(List<dynamic> a) {
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Header(level: 0, child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text("RECIBO", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)), pw.Text("Emitido por: ${a[0]}")])),
      pw.SizedBox(height: 20),
      pw.Text("Cliente: ${a[1]}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 20),
      _buildSmartTable(a[6], a[2], a[7], a[8], a[3]),
      pw.SizedBox(height: 20),
      pw.Align(alignment: pw.Alignment.centerRight, child: _buildPixArea(a[5])),
      pw.Spacer(),
      pw.Text("Data: ${a[4]}"),
      pw.Divider(borderStyle: pw.BorderStyle.dashed),
      pw.Center(child: pw.Text("Assinatura do Emissor")),
    ]);
  }

  // 2. MODERN
  static pw.Widget _buildModernLayout(List<dynamic> a) {
    final color = PdfColors.blue800;
    return pw.Column(children: [
      pw.Container(color: color, padding: const pw.EdgeInsets.all(20), child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text("RECIBO", style: pw.TextStyle(color: PdfColors.white, fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.Text(a[0], style: pw.TextStyle(color: PdfColors.white, fontSize: 14)),
      ])),
      pw.SizedBox(height: 20),
      pw.Container(padding: const pw.EdgeInsets.all(10), color: PdfColors.grey100, child: pw.Row(children: [pw.Text("CLIENTE: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)), pw.Text(a[1])])),
      pw.SizedBox(height: 20),
      _buildSmartTable(a[6], a[2], a[7], a[8], a[3], headerColor: color, headerTextColor: PdfColors.white),
      pw.SizedBox(height: 10),
      pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("TOTAL: ${a[3]}", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color))),
      pw.SizedBox(height: 20),
      if (a[5] != null) _buildPixArea(a[5]),
      pw.Spacer(),
      pw.Text("Emitido em ${a[4]}"),
    ]);
  }

  // 3. TECH
  static pw.Widget _buildTechLayout(List<dynamic> a) {
    const green = PdfColors.greenAccent;
    const bg = PdfColors.black;
    return pw.Container(color: bg, padding: const pw.EdgeInsets.all(20), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text("> SYSTEM.INIT_RECEIPT", style: pw.TextStyle(color: green, font: pw.Font.courier())),
      pw.Divider(color: green),
      pw.Text("ISSUER: ${a[0]}", style: pw.TextStyle(color: green, font: pw.Font.courier())),
      pw.Text("CLIENT: ${a[1]}", style: pw.TextStyle(color: green, font: pw.Font.courier())),
      pw.SizedBox(height: 20),
      pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all(color: green)), padding: const pw.EdgeInsets.all(10), child:
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(a[6] ? "ITEM: ${a[2]} (x${a[7]})" : "SERVICE: ${a[2]}", style: pw.TextStyle(color: green, font: pw.Font.courier())),
        pw.Text("TOTAL: ${a[3]}", style: pw.TextStyle(color: green, fontSize: 18, fontWeight: pw.FontWeight.bold, font: pw.Font.courier())),
      ])
      ),
      pw.SizedBox(height: 20),
      if (a[5] != null) pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all(color: green)), padding: const pw.EdgeInsets.all(5), child: _buildPixArea(a[5])),
      pw.Spacer(),
      pw.Text("> DATE: ${a[4]}", style: pw.TextStyle(color: green, font: pw.Font.courier())),
      pw.Text("> EOF", style: pw.TextStyle(color: green, font: pw.Font.courier())),
    ]));
  }

  // 4. PREMIUM
  static pw.Widget _buildPremiumLayout(List<dynamic> a) {
    final gold = PdfColors.amber700;
    return pw.Column(children: [
      pw.Container(decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: gold, width: 3))), child: pw.Text("RECIBO PREMIUM", style: pw.TextStyle(fontSize: 20, color: gold))),
      pw.SizedBox(height: 30),
      _buildGoldRow("EMISSOR", a[0], gold),
      _buildGoldRow("CLIENTE", a[1], gold),
      pw.SizedBox(height: 30),
      _buildSmartTable(a[6], a[2], a[7], a[8], a[3], headerColor: gold, headerTextColor: PdfColors.white),
      pw.SizedBox(height: 20),
      if (a[5] != null) _buildPixArea(a[5]),
      pw.Spacer(),
      pw.Text(a[4], style: pw.TextStyle(color: gold)),
    ]);
  }

  // 5. MINIMAL
  static pw.Widget _buildMinimalLayout(List<dynamic> a) {
    return pw.Center(child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
      pw.Text(a[0].toString().toUpperCase(), style: const pw.TextStyle(letterSpacing: 2, fontSize: 10)),
      pw.SizedBox(height: 40),
      pw.Text("${a[3]}", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      pw.Text("Pago por ${a[1]}", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
      pw.SizedBox(height: 40),
      pw.Text(a[6] ? "${a[7]}x ${a[2]}" : a[2], style: const pw.TextStyle(fontSize: 16)),
      pw.SizedBox(height: 40),
      if (a[5] != null) _buildPixArea(a[5]),
      pw.SizedBox(height: 40),
      pw.Text(a[4], style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
    ]));
  }

  // 6. CONSTRUCTION
  static pw.Widget _buildConstructionLayout(List<dynamic> a) {
    return pw.Column(children: [
      pw.Container(height: 20, color: PdfColors.orange800),
      pw.SizedBox(height: 10),
      pw.Text("ORDEM DE SERVIÇO", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 20),
      _buildRowLabelValue("Prestador", a[0]),
      _buildRowLabelValue("Cliente", a[1]),
      pw.SizedBox(height: 20),
      _buildSmartTable(a[6], a[2], a[7], a[8], a[3], headerColor: PdfColors.orange800, headerTextColor: PdfColors.white),
      pw.SizedBox(height: 20),
      if (a[5] != null) _buildPixArea(a[5]),
      pw.Spacer(),
      pw.Container(height: 20, color: PdfColors.black),
    ]);
  }

  // 7. CREATIVE
  static pw.Widget _buildCreativeLayout(List<dynamic> a) {
    return pw.Stack(children: [
      pw.Container(height: 150, decoration: const pw.BoxDecoration(color: PdfColors.purple, borderRadius: pw.BorderRadius.vertical(bottom: pw.Radius.circular(20)))),
      pw.Padding(padding: const pw.EdgeInsets.all(20), child: pw.Column(children: [
        pw.Text("Recibo Digital", style: pw.TextStyle(color: PdfColors.white, fontSize: 18)),
        pw.SizedBox(height: 20),
        pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(10), boxShadow: const [pw.BoxShadow(blurRadius: 5, color: PdfColors.grey300)]),
            child: pw.Column(children: [
              pw.Text("Valor Total", style: const pw.TextStyle(color: PdfColors.grey, fontSize: 10)),
              pw.Text("${a[3]}", style: pw.TextStyle(color: PdfColors.purple, fontSize: 30, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              _buildRowLabelValue("Para", a[1]),
              pw.SizedBox(height: 10),
              _buildSmartTable(a[6], a[2], a[7], a[8], a[3]),
              pw.SizedBox(height: 20),
              if (a[5] != null) _buildPixArea(a[5]),
            ])
        )
      ]))
    ]);
  }

  // 8. HEALTH
  static pw.Widget _buildHealthLayout(List<dynamic> a) {
    const teal = PdfColors.teal;
    return pw.Column(children: [
      pw.Row(children: [pw.Container(width: 10, height: 10, color: teal), pw.SizedBox(width: 5), pw.Text("Recibo de Saúde", style: const pw.TextStyle(color: teal, fontSize: 16))]),
      pw.SizedBox(height: 20),
      pw.Text(a[0], style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 30),
      _buildRowLabelValue("Paciente", a[1]),
      pw.SizedBox(height: 10),
      _buildSmartTable(a[6], a[2], a[7], a[8], a[3], headerColor: teal, headerTextColor: PdfColors.white),
      pw.SizedBox(height: 20),
      if (a[5] != null) _buildPixArea(a[5]),
      pw.Spacer(),
      pw.Text(a[4], style: const pw.TextStyle(color: teal)),
    ]);
  }

  // 9. RETRO
  static pw.Widget _buildRetroLayout(List<dynamic> a) {
    return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        decoration: pw.BoxDecoration(border: pw.Border.all(style: pw.BorderStyle.dashed)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Center(child: pw.Text("NOTA FISCAL", style: pw.TextStyle(font: pw.Font.courier(), fontSize: 20, fontWeight: pw.FontWeight.bold))),
          pw.Divider(borderStyle: pw.BorderStyle.dotted),
          pw.Text("DE: ${a[0]}", style: pw.TextStyle(font: pw.Font.courier())),
          pw.Text("PARA: ${a[1]}", style: pw.TextStyle(font: pw.Font.courier())),
          pw.SizedBox(height: 20),
          pw.Text(a[6] ? "QTD: ${a[7]} x ${a[2]} ......... ${a[3]}" : "SERV: ${a[2]} ......... ${a[3]}", style: pw.TextStyle(font: pw.Font.courier())),
          pw.SizedBox(height: 20),
          if (a[5] != null) _buildPixArea(a[5]),
          pw.Spacer(),
          pw.Text("DATA: ${a[4]}", style: pw.TextStyle(font: pw.Font.courier())),
        ])
    );
  }

  // 10. CORPORATE
  static pw.Widget _buildCorporateLayout(List<dynamic> a) {
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text("INVOICE", style: pw.TextStyle(color: PdfColors.red900, fontSize: 24, fontWeight: pw.FontWeight.bold)), pw.Text(a[0])]),
      pw.Divider(color: PdfColors.red900, thickness: 2),
      pw.SizedBox(height: 20),
      _buildRowLabelValue("Bill To", a[1]),
      pw.SizedBox(height: 20),
      _buildSmartTable(a[6], a[2], a[7], a[8], a[3], headerColor: PdfColors.red900, headerTextColor: PdfColors.white),
      pw.SizedBox(height: 20),
      pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("Total Due: ${a[3]}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
      if (a[5] != null) pw.Align(alignment: pw.Alignment.centerLeft, child: _buildPixArea(a[5])),
      pw.Spacer(),
      pw.Text(a[4]),
    ]);
  }

  // 11. DANFE
  static pw.Widget _buildDanfeLayout(String issuer, String client, String desc, String value, String date, String? pix, bool isProduct, String qty, String unitPrice) {
    final operationType = isProduct ? "VENDA DE MERCADORIA" : "PRESTAÇÃO DE SERVIÇO";
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all()), height: 60, child: pw.Row(children: [pw.Expanded(flex: 4, child: _buildBox("RECEBEMOS DE $issuer OS PRODUTOS/SERVIÇOS CONSTANTES DA NOTA", "", borderRight: true)), pw.Expanded(flex: 1, child: _buildBox("NF-e", "Nº 000.001", alignCenter: true))])),
      pw.SizedBox(height: 5),
      pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all()), height: 90, child: pw.Row(children: [pw.Expanded(flex: 4, child: pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(issuer.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)), pw.Spacer(), pw.Text("Natureza da Operação:", style: const pw.TextStyle(fontSize: 6)), pw.Text(operationType, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))]))), pw.Expanded(flex: 2, child: _buildBox("DANFE", "Documento Auxiliar\nda Nota Fiscal\nEletrônica", alignCenter: true, borderRight: true, borderLeft: true))])),
      pw.SizedBox(height: 5),
      pw.Container(decoration: pw.BoxDecoration(border: pw.Border.all()), child: pw.Row(children: [pw.Expanded(flex: 4, child: _buildBox("NOME / RAZÃO SOCIAL", client, borderRight: true)), pw.Expanded(flex: 1, child: _buildBox("DATA DA EMISSÃO", date))])),
      pw.SizedBox(height: 5),
      _buildSmartTable(isProduct, desc, qty, unitPrice, value),
      pw.SizedBox(height: 10),
      pw.Align(alignment: pw.Alignment.centerRight, child: _buildPixArea(pix)),
      pw.Spacer(),
      pw.Center(child: pw.Text("SEM VALOR FISCAL", style: pw.TextStyle(fontSize: 40, fontWeight: pw.FontWeight.bold, color: PdfColors.grey300))),
    ]);
  }


  // 12. PROFISSIONAL 1: ELEGANT
  static pw.Widget _buildProfElegant(List<dynamic> a) {
    const color = PdfColors.indigo900;
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Text(a[0].toString().toUpperCase(), style: pw.TextStyle(color: color, fontWeight: pw.FontWeight.bold, fontSize: 16)),
        pw.Text("RECIBO #${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
      ]),
      pw.Divider(color: color, thickness: 0.5),
      pw.SizedBox(height: 40),
      pw.Row(children: [
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("FATURADO PARA", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          pw.Text(a[1], style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
        ])),
        pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text("DATA DE EMISSÃO", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
          pw.Text(a[4], style: const pw.TextStyle(fontSize: 12)),
        ]))
      ]),
      pw.SizedBox(height: 30),
      _buildSmartTable(a[6], a[2], a[7], a[8], a[3], headerColor: color, headerTextColor: PdfColors.white),
      pw.SizedBox(height: 20),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
        pw.Text("TOTAL: ", style: const pw.TextStyle(fontSize: 12)),
        pw.Text("${a[3]}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
      ]),
      if (a[5] != null) pw.Align(alignment: pw.Alignment.centerLeft, child: _buildPixArea(a[5])),
      pw.Spacer(),
      pw.Center(child: pw.Text("Obrigado pela preferência", style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 10))),
    ]);
  }

  // 13. PROFISSIONAL 2: BOLD
  static pw.Widget _buildProfBold(List<dynamic> a) {
    return pw.Column(children: [
      pw.Container(
          color: PdfColors.black,
          padding: const pw.EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text(a[0], style: pw.TextStyle(color: PdfColors.yellow, fontWeight: pw.FontWeight.bold, fontSize: 20)),
            pw.Text("RECIBO", style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
          ])
      ),
      pw.SizedBox(height: 40),
      _buildRowLabelValue("CLIENTE", a[1]),
      pw.SizedBox(height: 20),
      _buildSmartTable(a[6], a[2], a[7], a[8], a[3], headerColor: PdfColors.black, headerTextColor: PdfColors.yellow),
      pw.SizedBox(height: 10),
      pw.Container(
          color: PdfColors.yellow,
          padding: const pw.EdgeInsets.all(10),
          child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text("TOTAL A PAGAR", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text("${a[3]}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          ])
      ),
      if (a[5] != null) _buildPixArea(a[5]),
      pw.Spacer(),
      pw.Text(a[4]),
    ]);
  }

  // 14. PROFISSIONAL 3: NATURE
  static pw.Widget _buildProfNature(List<dynamic> a) {
    const green = PdfColors.green800;
    return pw.Column(children: [
      pw.Row(children: [
        pw.Container(width: 40, height: 40, decoration: const pw.BoxDecoration(color: green, shape: pw.BoxShape.circle)),
        pw.SizedBox(width: 10),
        pw.Text(a[0], style: pw.TextStyle(color: green, fontSize: 20, fontWeight: pw.FontWeight.bold)),
      ]),
      pw.SizedBox(height: 30),
      pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(color: PdfColors.green50, borderRadius: pw.BorderRadius.circular(10)),
          child: pw.Column(children: [
            _buildRowLabelValue("Cliente", a[1]),
            pw.SizedBox(height: 5),
            _buildRowLabelValue("Data", a[4]),
          ])
      ),
      pw.SizedBox(height: 20),
      _buildSmartTable(a[6], a[2], a[7], a[8], a[3], headerColor: green, headerTextColor: PdfColors.white),
      if (a[5] != null) _buildPixArea(a[5]),
      pw.Spacer(),
      pw.Divider(color: green),
      pw.Center(child: pw.Text("Documento Ecológico - Não imprima se não for necessário", style: const pw.TextStyle(fontSize: 8, color: green))),
    ]);
  }

  // 15. PROFISSIONAL 4: ARCHITECT
  static pw.Widget _buildProfArchitect(List<dynamic> a) {
    return pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 3)),
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text("PROJETO / SERVIÇO", style: const pw.TextStyle(fontSize: 8, letterSpacing: 2)),
          pw.Text(a[0].toString().toUpperCase(), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 20),
          pw.Row(children: [
            pw.Expanded(child: _buildBox("CLIENTE", a[1], borderRight: true)),
            pw.Expanded(child: _buildBox("DATA", a[4])),
          ]),
          pw.SizedBox(height: 20),
          _buildSmartTable(a[6], a[2], a[7], a[8], a[3], headerColor: PdfColors.white, headerTextColor: PdfColors.black),
          pw.SizedBox(height: 20),
          pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text("TOTAL: ${a[3]}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16, decoration: pw.TextDecoration.underline))),
          if (a[5] != null) _buildPixArea(a[5]),
          pw.Spacer(),
        ])
    );
  }

  // 16. PROFISSIONAL 5: NEON
  static pw.Widget _buildProfNeon(List<dynamic> a) {
    const neon = PdfColors.pink500;
    const dark = PdfColors.blueGrey900;
    return pw.Container(
        color: dark,
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(children: [
          pw.Text(a[0], style: pw.TextStyle(color: neon, fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 40),
          pw.Text("RECIBO DIGITAL", style: const pw.TextStyle(color: PdfColors.white, letterSpacing: 5)),
          pw.SizedBox(height: 20),
          pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: neon), borderRadius: pw.BorderRadius.circular(10)),
              child: pw.Column(children: [
                _buildRowLabelValue("Cliente", a[1]),
                pw.Divider(color: PdfColors.grey700),
                _buildSmartTable(a[6], a[2], a[7], a[8], a[3], headerColor: neon, headerTextColor: PdfColors.white),
              ])
          ),
          pw.SizedBox(height: 20),
          if (a[5] != null) pw.Container(padding: const pw.EdgeInsets.all(5), color: PdfColors.white, child: _buildPixArea(a[5])),
          pw.Spacer(),
          pw.Text(a[4], style: const pw.TextStyle(color: PdfColors.grey)),
        ])
    );
  }

  static pw.Widget _buildBox(String label, String value, {bool borderRight = false, bool borderLeft = false, bool alignCenter = false}) {
    return pw.Container(padding: const pw.EdgeInsets.all(3), decoration: pw.BoxDecoration(border: pw.Border(right: borderRight ? const pw.BorderSide() : pw.BorderSide.none, left: borderLeft ? const pw.BorderSide() : pw.BorderSide.none)), child: pw.Column(crossAxisAlignment: alignCenter ? pw.CrossAxisAlignment.center : pw.CrossAxisAlignment.start, children: [pw.Text(label, style: const pw.TextStyle(fontSize: 5, color: PdfColors.grey700)), pw.Text(value, style: const pw.TextStyle(fontSize: 8))]));
  }
  static pw.Widget _buildRowLabelValue(String label, String value) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey600)), pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))]);
  }
  static pw.Widget _buildGoldRow(String label, String value, PdfColor color) {
    return pw.Row(children: [pw.Container(width: 5, height: 20, color: color), pw.SizedBox(width: 5), pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [pw.Text(label, style: pw.TextStyle(fontSize: 8, color: color)), pw.Text(value)])]);
  }
}