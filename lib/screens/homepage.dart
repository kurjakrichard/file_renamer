import 'package:flutter/material.dart';
import '../widgets/checkdir.dart';
import '../widgets/renamer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //bottomnavigation part
  int _selectedindex = 0;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar:
          _selectedindex == 0 ? appBar('File renamer') : appBar('Check dir'),
      body: _selectedindex == 0 ? const Renamer() : const CheckDir(),
      
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedindex,
          selectedItemColor: Colors.blue,
          onTap: navigateBottomBar,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'File renamer'),
            BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Check dir'),
          ]),
    );
  }

  AppBar appBar(String text) {
    return AppBar(
      backgroundColor: Colors.blue,
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void navigateBottomBar(int index) {
    setState(() {
      _selectedindex = index;
    });
  }
}
