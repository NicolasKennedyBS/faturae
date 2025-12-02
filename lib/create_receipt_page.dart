import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'pdf_util.dart';

class CreateReceiptPage extends StatefulWidget {
  const CreateReceiptPage({super.key});

  @override
  State<CreateReceiptPage> createState() => _CreateReceiptPageState();
}

class _CreateReceiptPageState extends State<CreateReceiptPage> {
  final _clientController = TextEditingController();
  final _serviceController = TextEditingController();
  final _valueController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Novo Recibo", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Preencha os dados do serviço",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _clientController,
              decoration: const InputDecoration(
                labelText: "Nome do Cliente",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _serviceController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Descrição do Serviço / Produto",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Valor (R\$)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: "Data",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_clientController.text.isEmpty || _valueController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Opa! Preencha pelo menos o Nome e o Valor."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  _showModelSelection(context);
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text(
                  "GERAR DOCUMENTO",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModelSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Escolha o Modelo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.description_outlined, size: 40),
                title: const Text("Modelo Simples"),
                subtitle: const Text("Econômico, ideal para impressão P&B."),
                onTap: () {
                  Navigator.pop(context);
                  _generatePdf(ReceiptStyle.simple);
                },
              ),
              const Divider(),

              ListTile(
                leading: Icon(Icons.star, size: 40, color: Colors.blue[800]),
                title: Text("Modelo Executivo", style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                subtitle: const Text("Design moderno com cabeçalho azul."),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
                  child: const Text("TOP", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _generatePdf(ReceiptStyle.modern);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _generatePdf(ReceiptStyle style) {
    PdfUtil.generateAndShowReceipt(
      clientName: _clientController.text,
      serviceDescription: _serviceController.text,
      value: _valueController.text,
      date: _dateController.text,
      style: style,
    );
  }
}