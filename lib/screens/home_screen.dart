import 'package:flutter/material.dart';
import '../models/qr_item.dart';
import 'generator_screen.dart';
import 'history_screen.dart';
import 'scanner_screen.dart';
import 'batch_generator_screen.dart';
import 'frame_designer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  String? _selectedData;
  String? _selectedTitle;
  String? _selectedType;

  void _navigateToGeneratorWithData(String data, String title, String type) {
    setState(() {
      _selectedData = data;
      _selectedTitle = title;
      _selectedType = type;
      _currentIndex = 0; // Switch to Generator tab
    });
  }

  void _navigateToGeneratorWithItem(QrItem item) {
    setState(() {
      _selectedData = item.data;
      _selectedTitle = item.title;
      _selectedType = item.type;
      _currentIndex = 0; // Switch to Generator tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      GeneratorScreen(
        key: ValueKey(_selectedData),
        initialData: _selectedData,
        initialTitle: _selectedTitle,
        initialType: _selectedType,
      ),
      ScannerScreen(onScanned: _navigateToGeneratorWithData),
      const BatchGeneratorScreen(),
      const FrameDesignerScreen(),
      HistoryScreen(onSelectHistoryItem: _navigateToGeneratorWithItem),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.qr_code_2),
            label: 'Generate',
          ),
          const NavigationDestination(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.playlist_add),
            label: 'Batch',
          ),
          NavigationDestination(
            icon: Icon(Icons.crop_original),
            label: 'Frames',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
