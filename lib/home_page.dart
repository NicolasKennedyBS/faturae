import 'package:flutter/material.dart';
import 'create_receipt_page.dart';
import 'settings_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 1;

  final List<Widget> _pages = [
    const HistoryPage(),
    const HomeContent(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: _selectedIndex == 1
          ? AppBar(
        toolbarHeight: 90,
        title: Image.asset(
          'assets/images/faturaetransparentname.png',
          height: 75,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      )
          : AppBar(
        title: Text(
            _selectedIndex == 0 ? "Documentos Gerados" : "Configurações",
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,

        indicatorColor: const Color(0xFF4C86D9).withOpacity(0.3),
        elevation: 2,
        height: 65,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF4C86D9)),
            label: 'Histórico',
          ),

          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF4C86D9)),
            label: 'Início',
          ),

          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: Color(0xFF4C86D9)),
            label: 'Config',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Text(
            "Toque abaixo para gerar um novo documento",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateReceiptPage()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text(
                "NOVO RECIBO",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              backgroundColor: const Color(0xFF4C86D9),
              foregroundColor: Colors.white,
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }
}