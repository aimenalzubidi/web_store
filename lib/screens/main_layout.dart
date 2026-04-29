import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/sidebar.dart';
import 'login_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'invoices_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ProductsScreen(),
    const OrdersScreen(),
    const InvoicesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            onLogout: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),

          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
