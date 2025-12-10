import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pdf_util.dart';
import 'pdf_preview_page.dart';

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
      String rawPrice = _unitPriceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      double price = (double.tryParse(rawPrice) ?? 0) / 100;
      double total = qty * price;
      if (total > 0) {
        _valueController.text = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(total);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(primary: Color(0xFF4C86D9), onPrimary: Colors.white, surface: Color(0xFF1E1E1E))
                : const ColorScheme.light(primary: Color(0xFF4C86D9), onPrimary: Colors.white, surface: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final inputColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F7FA);
    final borderColor = isDark ? Colors.transparent : const Color(0xFFE0E0E0);
    final primaryColor = const Color(0xFF4C86D9);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = Colors.grey[500]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          widget.receiptToEdit != null ? "Editar Documento" : "Novo Documento",
          style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: inputColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildModernSegmentButton("SERVIÇO", !_isProduct, primaryColor, textColor)),
                  Expanded(child: _buildModernSegmentButton("PRODUTO / VENDA", _isProduct, primaryColor, textColor)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle("DADOS DO EMISSOR"),
            _buildModernInput(
              controller: _issuerController,
              label: "Quem está emitindo?",
              icon: Icons.store_rounded,
              fillColor: inputColor,
              hintColor: hintColor,
            ),
            const SizedBox(height: 12),
            _buildModernInput(
              controller: _pixController,
              label: "Chave Pix (Opcional)",
              icon: Icons.pix_rounded,
              fillColor: inputColor,
              hintColor: hintColor,
            ),

            const SizedBox(height: 32),

            _buildSectionTitle("DADOS DO CLIENTE"),
            _buildModernInput(
              controller: _clientController,
              label: "Nome do Cliente",
              icon: Icons.person_rounded,
              fillColor: inputColor,
              hintColor: hintColor,
            ),

            const SizedBox(height: 32),

            _buildSectionTitle(_isProduct ? "ITENS DO PEDIDO" : "DETALHES DO SERVIÇO"),

            if (_isProduct) ...[
              Row(
                children: [
                  Expanded(flex: 2, child: _buildModernInput(controller: _codeController, label: "Cód.", hint: "001", fillColor: inputColor, hintColor: hintColor, isDense: true)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildModernInput(controller: _unitController, label: "Un.", hint: "UN", fillColor: inputColor, hintColor: hintColor, isDense: true)),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: _buildModernInput(controller: _qtyController, label: "Qtd", isNumber: true, fillColor: inputColor, hintColor: hintColor)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildModernInput(controller: _descriptionController, label: "Produto", icon: Icons.shopping_bag_outlined, fillColor: inputColor, hintColor: hintColor)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildModernInput(
                    controller: _unitPriceController,
                    label: "Unit.",
                    isNumber: true,
                    fillColor: inputColor,
                    hintColor: hintColor,
                    inputFormatters: [CurrencyInputFormatter()],
                  )),
                ],
              ),
            ] else ...[
              _buildModernInput(
                controller: _descriptionController,
                label: "Descrição do Serviço",
                icon: Icons.description_outlined,
                maxLines: 3,
                fillColor: inputColor,
                hintColor: hintColor,
              ),
            ],

            const SizedBox(height: 32),

            _buildSectionTitle("PAGAMENTO"),
            Row(
              children: [
                Expanded(
                  child: _buildModernInput(
                    controller: _dateController,
                    label: "Data",
                    icon: Icons.calendar_today_rounded,
                    fillColor: inputColor,
                    hintColor: hintColor,
                    isReadOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(width: 16),
                // VALOR TOTAL AGORA NA DIREITA
                Expanded(
                  child: _buildModernInput(
                    controller: _valueController,
                    label: "Valor Total",
                    isNumber: true,
                    isReadOnly: _isProduct,
                    fillColor: _isProduct ? (isDark ? Colors.black38 : Colors.grey.shade100) : inputColor,
                    hintColor: hintColor,
                    fontWeight: FontWeight.w800,
                    customTextColor: Colors.green,
                    fontSize: 18,
                    inputFormatters: [CurrencyInputFormatter()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  if (_issuerController.text.isEmpty || _clientController.text.isEmpty || _valueController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha os campos obrigatórios."), backgroundColor: Colors.red));
                    return;
                  }
                  _showModelSelection(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: primaryColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  widget.receiptToEdit != null ? "ATUALIZAR E GERAR" : "GERAR DOCUMENTO",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildModernSegmentButton(String label, bool isSelected, Color primaryColor, Color textColor) {
    return GestureDetector(
      onTap: () => setState(() => _isProduct = label.contains("PRODUTO")),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, spreadRadius: 1)] : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: isSelected ? textColor : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required Color fillColor,
    required Color hintColor,
    IconData? icon,
    String? hint,
    String? prefixText,
    bool isNumber = false,
    bool isReadOnly = false,
    int maxLines = 1,
    FontWeight fontWeight = FontWeight.normal,
    Color? customTextColor,
    double fontSize = 14,
    bool isDense = false,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade200 : Colors.transparent),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isDense ? 2 : 6),
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        onTap: onTap,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        style: TextStyle(fontWeight: fontWeight, color: customTextColor, fontSize: fontSize),
        decoration: InputDecoration(
          icon: icon != null ? Icon(icon, color: hintColor, size: 22) : null,
          labelText: label,
          labelStyle: TextStyle(color: hintColor, fontSize: 14, fontWeight: FontWeight.w500),
          hintText: hint,
          hintStyle: TextStyle(color: hintColor.withOpacity(0.7)),
          prefixText: prefixText,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Escolha o Estilo", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 40),
                  children: [
                    _buildGroupTitle("ESSENCIAIS"),
                    _buildModelOption(context, "DANFE", "Oficial e detalhado", Icons.receipt_long_rounded, Colors.blueGrey, ReceiptStyle.danfe),
                    _buildModelOption(context, "Simples", "Econômico e direto", Icons.article_outlined, Colors.grey, ReceiptStyle.simple),
                    _buildModelOption(context, "Executivo", "Azul Corporativo", Icons.business_center_rounded, const Color(0xFF0D47A1), ReceiptStyle.modern),

                    _buildGroupTitle("PREMIUM & PRO (NOVO)"),
                    _buildModelOption(context, "Elegante", "Minimalismo Fino", Icons.diamond_outlined, Colors.indigo, ReceiptStyle.prof_elegant),
                    _buildModelOption(context, "Bold", "Alto Contraste", Icons.campaign_rounded, Colors.black, ReceiptStyle.prof_bold),
                    _buildModelOption(context, "Arquitetura", "Linhas Técnicas", Icons.architecture_rounded, Colors.blueGrey, ReceiptStyle.prof_architect),
                    _buildModelOption(context, "Neon", "Futurista Dark", Icons.bolt_rounded, Colors.purpleAccent, ReceiptStyle.prof_neon),
                    _buildModelOption(context, "Natureza", "Eco Friendly", Icons.eco_rounded, Colors.green[800]!, ReceiptStyle.prof_nature),

                    _buildGroupTitle("LUXO & NEGÓCIOS"),
                    _buildModelOption(context, "Premium Gold", "Sofisticação", Icons.workspace_premium_rounded, Colors.amber[800]!, ReceiptStyle.premium),
                    _buildModelOption(context, "Corporativo", "Invoice Internacional", Icons.apartment_rounded, Colors.red[900]!, ReceiptStyle.corporate),
                    _buildModelOption(context, "Minimalista", "Design Clean Apple", Icons.circle_outlined, Colors.black, ReceiptStyle.minimal),

                    _buildGroupTitle("CRIATIVOS & NICHOS"),
                    _buildModelOption(context, "Tech Dev", "Estilo Terminal", Icons.terminal_rounded, Colors.green, ReceiptStyle.tech),
                    _buildModelOption(context, "Obras", "Construção Civil", Icons.construction_rounded, Colors.orange[800]!, ReceiptStyle.construction),
                    _buildModelOption(context, "Saúde", "Clínicas e Bem-estar", Icons.spa_rounded, Colors.teal, ReceiptStyle.health),
                    _buildModelOption(context, "Criativo", "Moderno (Roxo)", Icons.auto_awesome_rounded, Colors.purple, ReceiptStyle.creative),
                    _buildModelOption(context, "Retrô", "Nota Antiga", Icons.receipt_rounded, Colors.brown, ReceiptStyle.retro),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
    );
  }

  Widget _buildModelOption(BuildContext context, String title, String subtitle, IconData icon, Color color, ReceiptStyle style) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color)
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.pop(context);
          _navigateToPreview(style);
        },
      ),
    );
  }

  void _navigateToPreview(ReceiptStyle style) {
    var box = Hive.box('receipts');

    String finalDescription = _descriptionController.text;
    if (_isProduct) {
      finalDescription = "${_qtyController.text}x ${_descriptionController.text} (Un: R\$ ${_unitPriceController.text})";
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
      box.put(widget.hiveKey, receiptData);
    } else {
      box.add(receiptData);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreviewPage(
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
        ),
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String newText = formatter.format(value / 100);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}