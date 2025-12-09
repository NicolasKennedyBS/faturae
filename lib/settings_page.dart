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

  void _saveSettings() {
    settingsBox.put('default_name', _nameController.text);
    settingsBox.put('default_pix', _pixController.text);
    settingsBox.put('default_phone', _phoneController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dados salvos com sucesso!"), backgroundColor: Colors.green),
    );
  }

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
              Hive.box('receipts').clear();
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
    return ValueListenableBuilder(
        valueListenable: settingsBox.listenable(),
        builder: (context, Box box, _) {
          final isDark = box.get('isDarkMode', defaultValue: false);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: SwitchListTile(
                  title: const Text("Modo Escuro", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Economiza bateria e descansa a vista"),
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  value: isDark,
                  onChanged: (val) {
                    box.put('isDarkMode', val);
                  },
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Meus Dados (Padrão)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const Text("Preencha aqui para não precisar digitar em todo recibo."),
              const SizedBox(height: 20),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nome da Empresa / Emissor", prefixIcon: Icon(Icons.business), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _pixController,
                decoration: const InputDecoration(labelText: "Chave Pix (Opcional)", prefixIcon: Icon(Icons.pix), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Telefone / WhatsApp", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

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

              const Text("Gerenciamento", style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text("Limpar Histórico de Recibos"),
                onTap: _clearHistory,
              ),

              const SizedBox(height: 20),
              const Center(child: Text("Faturaê v1.1.0", style: TextStyle(color: Colors.grey))),
            ],
          );
        }
    );
  }
}