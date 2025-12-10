import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'create_receipt_page.dart';
import 'pdf_util.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Timer? _snackBarTimer;

  @override
  void dispose() {
    _snackBarTimer?.cancel();
    super.dispose();
  }

  void _showDeleteSnackBar(int key, Map receipt, Box box) {
    _snackBarTimer?.cancel();

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final deletedData = Map<String, dynamic>.from(receipt);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final actionColor = const Color(0xFF4C86D9);

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        content: Text(
            "Recibo apagado.",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)
        ),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade200, width: 1),
        ),
        margin: const EdgeInsets.all(20),
        dismissDirection: DismissDirection.horizontal,
        elevation: isDark ? 4 : 8,
        action: SnackBarAction(
          label: "DESFAZER",
          textColor: actionColor,
          onPressed: () {
            _snackBarTimer?.cancel();
            box.put(key, deletedData);
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );

    _snackBarTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        messenger.hideCurrentSnackBar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF4C86D9);
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ValueListenableBuilder(
      valueListenable: Hive.box('receipts').listenable(),
      builder: (context, Box box, widget) {

        final receipts = box.values.toList();
        final int totalCount = receipts.length;
        double totalValue = 0;

        for (var r in receipts) {
          String cleanValue = r['value'].toString().replaceAll(RegExp(r'[^0-9,]'), '').replaceAll(',', '.');
          totalValue += double.tryParse(cleanValue) ?? 0;
        }

        final formattedTotal = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(totalValue);
        final keys = box.keys.toList().cast<int>().reversed.toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 15),
              child: Text(
                "Faturaê: Profissionalize sua cobrança.",
                style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12, letterSpacing: 1.0, fontWeight: FontWeight.w500
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
                        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.description_outlined, color: primaryColor, size: 24),
                          const SizedBox(height: 10),
                          Text("Emitidos", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          Text("$totalCount", style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.attach_money, color: Colors.white, size: 24),
                          const SizedBox(height: 10),
                          const Text("Faturamento", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(formattedTotal, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [Text("Documentos Recentes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor))]),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: box.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open_rounded, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 10),
                    Text("Nenhum recibo ainda", style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: keys.length,
                itemBuilder: (context, index) {
                  final int key = keys[index];
                  final Map receipt = box.get(key);

                  return Dismissible(
                    key: ValueKey(key),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      box.delete(key);
                      _showDeleteSnackBar(key, receipt, box);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade100),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: isDark ? Colors.grey[800] : Colors.blue[50],
                          child: Icon(
                              receipt['isProduct'] == true ? Icons.shopping_bag_outlined : Icons.work_outline,
                              color: primaryColor, size: 20
                          ),
                        ),
                        title: Text(receipt['client'] ?? 'Sem Nome', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        subtitle: Text("${receipt['date']} • ${receipt['value']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateReceiptPage(receiptToEdit: receipt, hiveKey: key)));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.share_rounded, size: 20, color: primaryColor),
                              onPressed: () {
                                PdfUtil.generateAndShare(
                                  issuerName: receipt['issuer'],
                                  pixKey: receipt['pix'] ?? '',
                                  clientName: receipt['client'],
                                  serviceDescription: receipt['service'],
                                  value: receipt['value'],
                                  date: receipt['date'],
                                  style: ReceiptStyle.values[receipt['style']],
                                  isProduct: receipt['isProduct'] ?? false,
                                  qty: receipt['qty'] ?? '1',
                                  unitPrice: receipt['unitPrice'] ?? '',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}