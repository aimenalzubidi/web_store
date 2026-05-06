import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/sidebar.dart';
import 'login_screen.dart';
import 'products_screen.dart';
import 'orders_screen.dart';
import 'invoices_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  DateTime _lastSeenOrders = DateTime(2000);

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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('status', isEqualTo: 'Pending')
                .snapshots(),
            builder: (context, snapshot) {
              bool hasNewPending = false;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
                  if (createdAt != null && createdAt.isAfter(_lastSeenOrders)) {
                    hasNewPending = true;
                    break;
                  }
                }
              }

              // Also show badge if there are ANY pending orders and we haven't seen them yet
              // (e.g. at app start, _lastSeenOrders is now, so we won't show old ones.
              // If the user wants to see old pending ones too, we should initialize _lastSeenOrders differently)

              return Sidebar(
                selectedIndex: _selectedIndex,
                hasPendingOrders: hasNewPending && _selectedIndex != 1,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                    if (index == 1) {
                      _lastSeenOrders = DateTime.now();
                    }
                  });
                },
                onLogout: () async {
                  await FirebaseAuth.instance.signOut();
                },
              );
            },
          ),

          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
