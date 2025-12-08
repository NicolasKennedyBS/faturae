import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pdf_util.dart';

class CreateReceiptPage extends StatefulWidget {
  final Map? receiptToEdit;
  final int? hiveKey;

  const CreateReceiptPage({super.key, this.receiptToEdit, this.hiveKey});

  @override
  State<CreateReceiptPage> createState() => _CreateReceiptPageState();
}

class _CreateReceiptPageState extends State<CreateReceiptPage> {
  final _issuerController = TextEditingController();
  final _clientController = TextEditingController();
  final _serviceController = TextEditingController();
  final _valueController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.receiptToEdit != null) {
      _issuerController.text = widget.receiptToEdit!['issuer'];
      _clientController.text = widget.receiptToEdit!['client'];
      _serviceController.text = widget.receiptToEdit!['service'];
      _valueController.text = widget.receiptToEdit!['value'];
      _dateController.text = widget.receiptToEdit!['date'];
    } else {
      _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      var settingsBox = Hive.box('settings');
      _issuerController.text = settingsBox.get('default_name', defaultValue: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.receiptToEdit != null ? "Editar Recibo" : "Novo Recibo",
            style: const TextStyle(color: Colors.white)
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: TextField(
                controller: _issuerController,
                decoration: const InputDecoration(
                  labelText: "Quem está emitindo?",
                  border: InputBorder.none,
                  icon: Icon(Icons.badge, color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text("Dados do Serviço", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            TextField(
              controller: _clientController,
              decoration: const InputDecoration(labelText: "Nome do Cliente", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _serviceController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Descrição do Serviço", border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: TextField(controller: _valueController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Valor (R\$)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _dateController, decoration: const InputDecoration(labelText: "Data", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)))),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_issuerController.text.isEmpty || _clientController.text.isEmpty || _valueController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha: Seu Nome, Cliente e Valor."), backgroundColor: Colors.red));
                    return;
                  }
                  _showModelSelection(context);
                },
                icon: const Icon(Icons.check),
                label: Text(
                    widget.receiptToEdit != null ? "SALVAR E GERAR PDF" : "GERAR DOCUMENTO",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Escolha o Estilo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
              ]),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _buildModelOption(context, "DANFE (Nota Fiscal)", "Estilo documento oficial", Icons.receipt_long, Colors.blueGrey, ReceiptStyle.danfe),
                    _buildModelOption(context, "Simples", "Econômico, ideal para P&B", Icons.description_outlined, Colors.grey, ReceiptStyle.simple),
                    _buildModelOption(context, "Executivo", "Azul Profissional", Icons.business, Colors.blue[800]!, ReceiptStyle.modern),
                    _buildModelOption(context, "Tech Dev", "Hacker", Icons.terminal, Colors.green, ReceiptStyle.tech),
                    _buildModelOption(context, "Premium Gold", "Sofisticado", Icons.workspace_premium, Colors.amber[800]!, ReceiptStyle.premium),
                    _buildModelOption(context, "Minimalista", "Design Clean", Icons.circle_outlined, Colors.black, ReceiptStyle.minimal),
                    _buildModelOption(context, "Obras & Construção", "Forte e Visível", Icons.construction, Colors.orange[800]!, ReceiptStyle.construction),
                    _buildModelOption(context, "Criativo", "Roxo Moderno", Icons.auto_awesome, Colors.purple, ReceiptStyle.creative),
                    _buildModelOption(context, "Saúde & Bem-estar", "Relaxante", Icons.spa, Colors.teal, ReceiptStyle.health),
                    _buildModelOption(context, "Retrô", "Nota Fiscal Antiga", Icons.receipt, Colors.brown, ReceiptStyle.retro),
                    _buildModelOption(context, "Corporativo", "Internacional", Icons.apartment, Colors.red[900]!, ReceiptStyle.corporate),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModelOption(BuildContext context, String title, String subtitle, IconData icon, Color color, ReceiptStyle style) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.pop(context);
          _saveAndGeneratePdf(style);
        },
      ),
    );
  }

  void _saveAndGeneratePdf(ReceiptStyle style) async {
    var box = Hive.box('receipts');

    final receiptData = {
      'id': widget.receiptToEdit != null ? widget.receiptToEdit!['id'] : DateTime.now().millisecondsSinceEpoch.toString(), // Mantém ID se editando
      'issuer': _issuerController.text,
      'client': _clientController.text,
      'service': _serviceController.text,
      'value': _valueController.text,
      'date': _dateController.text,
      'style': style.index,
      'createdAt': DateTime.now().toString(),
    };

    if (widget.hiveKey != null) {
      await box.put(widget.hiveKey, receiptData);
      print("Recibo atualizado!");
    } else {
      await box.add(receiptData);
      print("Recibo criado!");
    }

    if (mounted && widget.hiveKey != null) {
      Navigator.pop(context);
    }

    await PdfUtil.generateAndShare(
      issuerName: _issuerController.text,
      clientName: _clientController.text,
      serviceDescription: _serviceController.text,
      value: _valueController.text,
      date: _dateController.text,
      style: style,
    );
  }
}