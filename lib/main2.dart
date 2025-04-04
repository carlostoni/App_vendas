import 'package:flutter/material.dart';
import 'cadastro_produto_page.dart'; 


// Nova ideia de tela inicial nao implementado 


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'Produtos', 'icon': Icons.shopping_bag, 'page': ProdutosPage()},
    {'title': 'Cadastro', 'icon': Icons.person_add, 'page': CadastroProdutoPage(onSalvar: (nome, peso, quantidade, preco, categoria, unidade) {})},
    {'title': 'Pedidos', 'icon': Icons.receipt, 'page': PedidosPage()},
    {'title': 'Clientes', 'icon': Icons.people, 'page': ClientesPage()},
    {'title': 'Calendário', 'icon': Icons.calendar_today, 'page': CalendarioPage()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 30,
            mainAxisSpacing: 200,
            children: menuItems.map((item) {
              return _buildMenuButton(context, item['title'], item['icon'], item['page']);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Páginas de exemplo
class ProdutosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produtos')),
      body: Center(child: Text('Página de Produtos')),
    );
  }
}

class PedidosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedidos')),
      body: Center(child: Text('Página de Pedidos')),
    );
  }
}

class ClientesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clientes')),
      body: Center(child: Text('Página de Clientes')),
    );
  }
}

class CalendarioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendário')),
      body: Center(child: Text('Página de Calendário')),
    );
  }
}