import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pdf_util.dart';
import 'create_receipt_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('receipts').listenable(),
      builder: (context, Box box, widget) {

        if (box.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 10),
                const Text("Nenhum documento salvo.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final keys = box.keys.toList().cast<int>().reversed.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(10),
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
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 30),
              ),

              onDismissed: (direction) {
                // Deleta do Banco de Dados
                box.delete(key);

                // Mostra aviso com opção de desfazer
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Recibo apagado."),
                    action: SnackBarAction(
                      label: "DESFAZER",
                      onPressed: () {
                        box.put(key, receipt);
                      },
                    ),
                  ),
                );
              },

              child: Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.description, color: Colors.blue),
                  ),
                  title: Text(
                    receipt['client'] ?? 'Cliente',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${receipt['date']} • R\$ ${receipt['value']}"),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        tooltip: "Editar",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateReceiptPage(
                                receiptToEdit: receipt,
                                hiveKey: key,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.grey),
                        tooltip: "Reenviar PDF",
                        onPressed: () {
                          PdfUtil.generateAndShare(
                            issuerName: receipt['issuer'],
                            clientName: receipt['client'],
                            serviceDescription: receipt['service'],
                            value: receipt['value'],
                            date: receipt['date'],
                            style: ReceiptStyle.values[receipt['style']],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}