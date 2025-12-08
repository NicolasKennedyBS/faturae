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
    const Center(child: Text("Configurações em breve...")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],


      appBar: _selectedIndex == 1
          ? AppBar(
        title: Image.asset('assets/images/faturaetransparentname.png', height: 55),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      )
          : AppBar(
        title: Text(
            _selectedIndex == 0 ? "Documentos Gerados" : "Configurações",
            style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),

      body: _pages[_selectedIndex],

      // DOCK INFERIOR
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: Colors.blue.shade100,
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
          Opacity(
            opacity: 0.5,
            child: SizedBox(
              width: 200,
              child: Image.asset('assets/images/faturaelogotransp.png'),
            ),
          ),
          const SizedBox(height: 20),
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