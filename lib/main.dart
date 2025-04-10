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
      theme: ThemeData(
        scaffoldBackgroundColor:
            Colors.white, // 🔹 Fundo branco para todas as telas
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // 🔹 Deixa a AppBar branca
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ), // 🔹 Ícones pretos para contraste
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ), // 🔹 Texto preto
        ),
      ),
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

  Map<String, List<Map<String, dynamic>>> _categoriasComProdutos() {
    Map<String, List<Map<String, dynamic>>> categoriasMap = {};
    for (var produto in produtosCadastrados) {
      final categoria = produto['categoria'];
      if (!categoriasMap.containsKey(categoria)) {
        categoriasMap[categoria] = [];
      }
      categoriasMap[categoria]!.add(produto);
    }
    return categoriasMap;
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final produtosString = prefs.getString('produtosCadastrados');
    final pedidosString = prefs.getString('pedidosSalvos');

    if (produtosString != null) {
      setState(() {
        produtosCadastrados = List<Map<String, dynamic>>.from(
          jsonDecode(produtosString),
        );
      });
    }

    if (pedidosString != null) {
      setState(() {
        pedidosSalvos = List<Map<String, dynamic>>.from(
          jsonDecode(pedidosString),
        );
      });
    }
  }

  Future<void> salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('produtosCadastrados', jsonEncode(produtosCadastrados));
    prefs.setString('pedidosSalvos', jsonEncode(pedidosSalvos));
  }

  void adicionarProduto(
    String nome,
    double peso,
    int quantidade,
    double preco,
    String categoria,
    String unidade,
  ) {
    setState(() {
      produtosCadastrados.add({
        'nome': nome,
        'peso': peso,
        'quantidade': quantidade,
        'preco': preco,
        'categoria': categoria,
        'unidade': unidade,
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

    TextEditingController precoController = TextEditingController(
      text: produtosCadastrados[index]['preco'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Produto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantidade'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: precoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Preço (R\$)'),
              ),
            ],
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
                  int novaQuantidade =
                      int.tryParse(quantidadeController.text) ?? 1;
                  double novoPreco =
                      double.tryParse(precoController.text) ?? 0.0;

                  produtosCadastrados[index]['quantidade'] = novaQuantidade;
                  produtosCadastrados[index]['preco'] = novoPreco;
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
            decoration: InputDecoration(
              labelText: 'Digite uma observação (opcional)',
            ),
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
                MaterialPageRoute(
                  builder:
                      (context) =>
                          CadastroProdutoPage(onSalvar: adicionarProduto),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PedidosSalvosPage(pedidos: pedidosSalvos),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white, // Aqui você define a cor de fundo
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children:
                  _categoriasComProdutos().entries.map((entry) {
                    final categoria = entry.key;
                    final produtos = entry.value;

                    return ExpansionTile(
                      title: Text(
                        categoria,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: produtos.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.1,
                              ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 8,
                          ),
                          itemBuilder: (context, index) {
                            final produto = produtos[index];
                            final globalIndex = produtosCadastrados.indexOf(
                              produto,
                            );

                            return GestureDetector(
                              onTap: () => selecionarProduto(globalIndex),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  border: Border.all(
                                    color:
                                        produtosSelecionados.contains(
                                              globalIndex,
                                            )
                                            ? Colors.blue
                                            : Colors.black,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      produto['nome'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      "Peso: ${produto['peso']}${produto['unidade']}",
                                    ),
                                    Text("R\$ ${produto['preco']}"),
                                    Text("Qtd: ${produto['quantidade']}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: finalizarPedido,
              child: Text('FINALIZAR PEDIDO'),
            ),
          ),
        ],
      ),
    );
  }
}
