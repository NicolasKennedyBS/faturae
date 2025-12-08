import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();
  final _pixController = TextEditingController();
  final _phoneController = TextEditingController();

  final Box settingsBox = Hive.box('settings');

  @override
  void initState() {
    super.initState();
    _nameController.text = settingsBox.get('default_name', defaultValue: '');
    _pixController.text = settingsBox.get('default_pix', defaultValue: '');
    _phoneController.text = settingsBox.get('default_phone', defaultValue: '');
  }

  // Função para salvar tudo
  void _saveSettings() {
    settingsBox.put('default_name', _nameController.text);
    settingsBox.put('default_pix', _pixController.text);
    settingsBox.put('default_phone', _phoneController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dados salvos com sucesso!"), backgroundColor: Colors.green),
    );
  }

  // Função para limpar histórico
  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Apagar Histórico?"),
        content: const Text("Isso vai apagar todos os recibos salvos. Não dá para desfazer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              Hive.box('receipts').clear(); // Limpa a caixa de recibos
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Histórico limpo.")));
            },
            child: const Text("Apagar Tudo", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Meus Dados (Padrão)",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        const Text("Preencha aqui para não precisar digitar em todo recibo."),
        const SizedBox(height: 20),

        // Campo Nome/Empresa
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: "Nome da Empresa / Emissor",
            prefixIcon: Icon(Icons.business),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),

        TextField(
          controller: _pixController,
          decoration: const InputDecoration(
            labelText: "Chave Pix (Opcional)",
            prefixIcon: Icon(Icons.pix),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),

        // Campo Telefone
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: "Telefone / WhatsApp",
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),

        // Botão Salvar
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text("SALVAR DADOS PADRÃO"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C86D9),
              foregroundColor: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 20),

        const Text("Gerenciamento de Dados", style: TextStyle(fontWeight: FontWeight.bold)),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text("Limpar Histórico de Recibos"),
          onTap: _clearHistory,
        ),

        const SizedBox(height: 20),
        const Center(child: Text("Faturaê v1.0.0", style: TextStyle(color: Colors.grey))),
      ],
    );
  }
}