import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
        title: Text('Pedidos'),
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
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
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
                      borderRadius: BorderRadius.circular(8),
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
          ElevatedButton(
            onPressed: finalizarPedido,
            child: Text('FINALIZAR PEDIDO'),
          ),
        ],
      ),
    );
  }
}

class CadastroProdutoPage extends StatelessWidget {
  final Function(String, double, int, String) onSalvar;

  CadastroProdutoPage({required this.onSalvar});

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final List<String> categorias = ['Alimentos', 'Vestuário', 'Eletrodomésticos', 'Móveis']; // Exemplos de categorias

  @override
  Widget build(BuildContext context) {
    String categoriaSelecionada = categorias[0]; // Categoria padrão

    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome do Produto'),
            ),
            TextField(
              controller: _pesoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Peso (kg)'),
            ),
            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantidade'),
            ),
            DropdownButton<String>(
              value: categoriaSelecionada,
              onChanged: (String? newValue) {
                categoriaSelecionada = newValue!;
              },
              items: categorias.map<DropdownMenuItem<String>>((String categoria) {
                return DropdownMenuItem<String>(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final nome = _nomeController.text;
                final peso = double.tryParse(_pesoController.text) ?? 0.0;
                final quantidade = int.tryParse(_quantidadeController.text) ?? 1;
                onSalvar(nome, peso, quantidade, categoriaSelecionada);
                Navigator.pop(context);
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}


class PedidosSalvosPage extends StatefulWidget {
  final List<Map<String, dynamic>> pedidos;  // Mudado para List<Map<String, dynamic>>

  PedidosSalvosPage({required this.pedidos});

  @override
  _PedidosSalvosPageState createState() => _PedidosSalvosPageState();
}

class _PedidosSalvosPageState extends State<PedidosSalvosPage> {
  List<bool> _expandidos = [];

  @override
  void initState() {
    super.initState();
    _expandidos = List.generate(widget.pedidos.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedidos Salvos')),
      body: ListView.builder(
        itemCount: widget.pedidos.length,
        itemBuilder: (context, index) {
          // Obter a observação do pedido
          String observacao = widget.pedidos[index]['observacao'] ?? 'Sem observação';

          return ExpansionTile(
            title: Text('Pedido ${index + 1}'),
            initiallyExpanded: _expandidos[index],
            onExpansionChanged: (expanded) {
              setState(() {
                _expandidos[index] = expanded;
              });
            },
            children: [
              // Mostrar os itens do pedido
              ...widget.pedidos[index]['itens']
                  .map((produto) => ListTile(
                        title: Text(
                            "${produto['nome']} - ${produto['peso']}kg - Qtd: ${produto['quantidade']}"),
                      ))
                  .toList(),
              // Adicionar a observação logo abaixo dos itens
              ListTile(
                title: Text(
                  'Observação: $observacao',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
