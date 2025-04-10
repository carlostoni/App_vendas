import 'package:flutter/material.dart';
import 'pedidos_page.dart';

void main() {
  runApp(PedidosApp());
}

class PedidosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          elevation: 10,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 26),
        ),
      ),
      home: Material(elevation: 50, child: PedidosPage()),
    );
  }
}
