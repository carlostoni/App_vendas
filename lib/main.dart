import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'cadastro_produto_page.dart';
import 'pedidos_salvos.dart';
void main() {
  runApp(PedidosApp());
}

class PedidosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PedidosPage(),
    );
  }
}

class PedidosPage extends StatefulWidget {
  @override
  _PedidosPageState createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  List<Map<String, dynamic>> produtosCadastrados = [];
  List<Map<String, dynamic>> pedidosSalvos = [];
  List<Map<String, dynamic>> pedidoAtual = [];
  Set<int> produtosSelecionados = {};

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final produtosString = prefs.getString('produtosCadastrados');
    final pedidosString = prefs.getString('pedidosSalvos');

    if (produtosString != null) {
      setState(() {
        produtosCadastrados = List<Map<String, dynamic>>.from(jsonDecode(produtosString));
      });
    }

    if (pedidosString != null) {
      setState(() {
        pedidosSalvos = List<Map<String, dynamic>>.from(jsonDecode(pedidosString));
      });
    }
  }

  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('produtosCadastrados', jsonEncode(produtosCadastrados));
    prefs.setString('pedidosSalvos', jsonEncode(pedidosSalvos));
  }

 void adicionarProduto(String nome, double peso, int quantidade, String categoria) {
  setState(() {
    produtosCadastrados.add({
      'nome': nome,
      'peso': peso,
      'quantidade': quantidade,
      'categoria': categoria, // Adicionando a categoria
    });
  });
  salvarDados();
}
void excluirProduto(int index) {
    setState(() {
      produtosCadastrados.removeAt(index);
    });
    salvarDados();
  }

  void selecionarProduto(int index) {
    setState(() {
      if (produtosSelecionados.contains(index)) {
        produtosSelecionados.remove(index);
      } else {
        produtosSelecionados.add(index);
      }
    });
    editarQuantidade(index);
  }

  void editarQuantidade(int index) {
    TextEditingController quantidadeController = TextEditingController(
      text: produtosCadastrados[index]['quantidade'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Quantidade'),
          content: TextField(
            controller: quantidadeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Quantidade'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  int novaQuantidade = int.tryParse(quantidadeController.text) ?? 1;
                  produtosCadastrados[index]['quantidade'] = novaQuantidade;
                  pedidoAtual.add(produtosCadastrados[index]);
                });
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
             TextButton(
              onPressed: () {
                excluirProduto(index);
                Navigator.pop(context);
              },
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  

  void finalizarPedido() {
    TextEditingController observacaoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Observação do Pedido'),
          content: TextField(
            controller: observacaoController,
            decoration: InputDecoration(labelText: 'Digite uma observação (opcional)'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (pedidoAtual.isNotEmpty) {
                  setState(() {
                    pedidosSalvos.add({
                      'itens': List.from(pedidoAtual),
                      'observacao': observacaoController.text,
                    });
                    pedidoAtual.clear();
                    produtosSelecionados.clear();
                  });
                  salvarDados();
                }
                Navigator.pop(context);
              },
              child: Text('Finalizar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroProdutoPage(onSalvar: adicionarProduto)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
        context,
          MaterialPageRoute(builder: (context) => PedidosSalvosPage(pedidos: pedidosSalvos)),  // Já é List<Map<String, dynamic>>
);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Ajuste o valor conforme necessário
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: produtosCadastrados.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      selecionarProduto(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: produtosSelecionados.contains(index) ? Colors.blue : Colors.black,
                          width: produtosSelecionados.contains(index) ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(30), // Se não quiser bordas arredondadas
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(produtosCadastrados[index]['nome']),
                            Text("Peso: ${produtosCadastrados[index]['peso']}kg"),
                            Text("Qtd: ${produtosCadastrados[index]['quantidade']}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: finalizarPedido,
            child: Text('FINALIZAR PEDIDO'),
          ),
        ],
      ),
    );
  }
}
