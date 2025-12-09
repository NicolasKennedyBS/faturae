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
  final _pixController = TextEditingController();
  final _clientController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _dateController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _unitPriceController = TextEditingController();
  final _codeController = TextEditingController();
  final _unitController = TextEditingController(text: 'UN');

  bool _isProduct = false;

  @override
  void initState() {
    super.initState();
    _qtyController.addListener(_calculateTotal);
    _unitPriceController.addListener(_calculateTotal);

    if (widget.receiptToEdit != null) {
      final r = widget.receiptToEdit!;
      _issuerController.text = r['issuer'];
      _pixController.text = r['pix'] ?? '';
      _clientController.text = r['client'];
      _valueController.text = r['value'];
      _dateController.text = r['date'];

      _isProduct = r['isProduct'] ?? false;
      if (_isProduct) {
        _descriptionController.text = r['rawService'] ?? '';
        _qtyController.text = r['qty'] ?? '1';
        _unitPriceController.text = r['unitPrice'] ?? '';
        _codeController.text = r['code'] ?? '';
        _unitController.text = r['unit'] ?? 'UN';
      } else {
        _descriptionController.text = r['service'];
      }
    } else {
      _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      var settingsBox = Hive.box('settings');
      _issuerController.text = settingsBox.get('default_name', defaultValue: '');
      _pixController.text = settingsBox.get('default_pix', defaultValue: '');
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_isProduct) {
      double qty = double.tryParse(_qtyController.text) ?? 0;
      String cleanPrice = _unitPriceController.text.replaceAll('R\$', '').replaceAll('.', '').replaceAll(',', '.');
      double price = double.tryParse(cleanPrice) ?? 0;
      double total = qty * price;
      if (total > 0) {
        final formatter = NumberFormat("#,##0.00", "pt_BR");
        _valueController.text = formatter.format(total);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inputFillColor = isDark ? Colors.grey[800] : Colors.white;
    final readOnlyFillColor = isDark ? Colors.grey[900] : Colors.grey[200];
    final toggleSelectedColor = isDark ? Colors.grey[700] : colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiptToEdit != null ? "Editar Documento" : "Novo Documento", style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: inputFillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isProduct = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isProduct ? toggleSelectedColor : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                        ),
                        child: Text(
                          "SERVIÇO",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: !_isProduct ? Colors.white : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isProduct = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isProduct ? toggleSelectedColor : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(11)),
                        ),
                        child: Text(
                          "PRODUTO / VENDA",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: _isProduct ? Colors.white : Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2228) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark ? Colors.blue.withOpacity(0.2) : Colors.blue.shade100
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _issuerController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                        labelText: "Quem está emitindo?",
                        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                        border: InputBorder.none,
                        icon: Icon(Icons.store, color: colorScheme.primary)
                    ),
                  ),
                  Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  TextField(
                    controller: _pixController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                        labelText: "Chave Pix (Opcional)",
                        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                        border: InputBorder.none,
                        icon: const Icon(Icons.pix, color: Colors.green)
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text("Detalhes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            TextField(
              controller: _clientController,
              decoration: InputDecoration(
                labelText: "Nome do Cliente",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
                filled: true, fillColor: inputFillColor,
              ),
            ),
            const SizedBox(height: 15),

            if (_isProduct) ...[
              Row(
                children: [
                  Expanded(flex: 2, child: TextField(controller: _codeController, decoration: InputDecoration(labelText: "Cód.", hintText: "001", border: const OutlineInputBorder(), filled: true, fillColor: inputFillColor))),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: TextField(controller: _unitController, decoration: InputDecoration(labelText: "Un.", hintText: "UN", border: const OutlineInputBorder(), filled: true, fillColor: inputFillColor))),
                  const SizedBox(width: 10),
                  Expanded(flex: 3, child: TextField(controller: _qtyController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Qtd", border: const OutlineInputBorder(), filled: true, fillColor: inputFillColor))),
                ],
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(flex: 2, child: TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Nome do Produto", border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.shopping_bag_outlined), filled: true, fillColor: inputFillColor))),
                  const SizedBox(width: 10),
                  Expanded(flex: 1, child: TextField(controller: _unitPriceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Unit. (R\$)", border: const OutlineInputBorder(), filled: true, fillColor: inputFillColor))),
                ],
              ),
            ] else ...[
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Descrição do Serviço",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.build),
                  filled: true, fillColor: inputFillColor,
                ),
              ),
            ],

            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    readOnly: _isProduct,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                    decoration: InputDecoration(
                      labelText: "Valor Total (R\$)",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.attach_money),
                      filled: true,
                      fillColor: _isProduct ? readOnlyFillColor : inputFillColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: "Data",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      filled: true, fillColor: inputFillColor,
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
                  if (_issuerController.text.isEmpty || _clientController.text.isEmpty || _valueController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha os campos obrigatórios."), backgroundColor: Colors.red));
                    return;
                  }
                  _showModelSelection(context);
                },
                icon: const Icon(Icons.check_circle_outline),
                label: Text(widget.receiptToEdit != null ? "ATUALIZAR E GERAR" : "GERAR DOCUMENTO", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white, elevation: 3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModelSelection(BuildContext context) {
    final modalColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: modalColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Escolha o Layout", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text("Essenciais", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    _buildModelOption(context, "DANFE (Nota Fiscal)", "Estilo oficial", Icons.receipt_long, Colors.blueGrey, ReceiptStyle.danfe),
                    _buildModelOption(context, "Simples", "Econômico (P&B)", Icons.description_outlined, Colors.grey, ReceiptStyle.simple),
                    _buildModelOption(context, "Executivo", "Azul Profissional", Icons.business, Colors.blue[800]!, ReceiptStyle.modern),
                    _buildModelOption(context, "Tech Dev", "Hacker / Terminal", Icons.terminal, Colors.green, ReceiptStyle.tech),

                    const Divider(height: 30),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text("Criativos", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                    _buildModelOption(context, "Premium Gold", "Luxo e Sofisticação", Icons.workspace_premium, Colors.amber[800]!, ReceiptStyle.premium),
                    _buildModelOption(context, "Minimalista", "Design Clean Apple", Icons.circle_outlined, Colors.black, ReceiptStyle.minimal),
                    _buildModelOption(context, "Obras & Construção", "Forte e Visível", Icons.construction, Colors.orange[800]!, ReceiptStyle.construction),
                    _buildModelOption(context, "Criativo", "Roxo Moderno (Nubank)", Icons.auto_awesome, Colors.purple, ReceiptStyle.creative),
                    _buildModelOption(context, "Saúde & Bem-estar", "Relaxante", Icons.spa, Colors.teal, ReceiptStyle.health),
                    _buildModelOption(context, "Retrô", "Nota Fiscal Antiga", Icons.receipt, Colors.brown, ReceiptStyle.retro),
                    _buildModelOption(context, "Corporativo", "Internacional", Icons.apartment, Colors.red[900]!, ReceiptStyle.corporate),

                    const Divider(height: 30),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 5),
                      Text("Profissionais (Novo)", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    ]),
                    const SizedBox(height: 10),

                    _buildModelOption(context, "Elegante", "Azul Sereno e Fino", Icons.diamond_outlined, Colors.indigo, ReceiptStyle.prof_elegant),
                    _buildModelOption(context, "Bold Impact", "Alto Contraste (Preto/Amarelo)", Icons.campaign, Colors.black, ReceiptStyle.prof_bold),
                    _buildModelOption(context, "Eco Nature", "Sustentável e Verde", Icons.eco, Colors.green[800]!, ReceiptStyle.prof_nature),
                    _buildModelOption(context, "Arquiteto", "Linhas Técnicas", Icons.architecture, Colors.blueGrey[900]!, ReceiptStyle.prof_architect),
                    _buildModelOption(context, "Neon Digital", "Futurista Dark", Icons.bolt, Colors.pinkAccent, ReceiptStyle.prof_neon),

                    const SizedBox(height: 40),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2228) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
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

    String finalDescription = _descriptionController.text;
    if (_isProduct) {
      finalDescription = "${_qtyController.text}x $_finalDescription (Un: R\$ ${_unitPriceController.text})";
    }

    final receiptData = {
      'id': widget.receiptToEdit != null ? widget.receiptToEdit!['id'] : DateTime.now().millisecondsSinceEpoch.toString(),
      'issuer': _issuerController.text,
      'pix': _pixController.text,
      'client': _clientController.text,
      'service': finalDescription,
      'rawService': _descriptionController.text,
      'value': _valueController.text,
      'date': _dateController.text,
      'style': style.index,
      'isProduct': _isProduct,
      'qty': _qtyController.text,
      'unitPrice': _unitPriceController.text,
      'code': _codeController.text,
      'unit': _unitController.text,
      'createdAt': DateTime.now().toString(),
    };

    if (widget.hiveKey != null) {
      await box.put(widget.hiveKey, receiptData);
    } else {
      await box.add(receiptData);
    }

    if (mounted && widget.hiveKey != null) Navigator.pop(context);

    await PdfUtil.generateAndShare(
      issuerName: _issuerController.text,
      pixKey: _pixController.text,
      clientName: _clientController.text,
      serviceDescription: _descriptionController.text,
      value: _valueController.text,
      date: _dateController.text,
      style: style,
      isProduct: _isProduct,
      qty: _qtyController.text,
      unitPrice: _unitPriceController.text,
    );
  }

  String get _finalDescription => _descriptionController.text;
}