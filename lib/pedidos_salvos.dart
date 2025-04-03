import 'package:flutter/material.dart';
import 'pdf_generator.dart'; // Importando a nova classe

class PedidosSalvosPage extends StatefulWidget {
  final List<Map<String, dynamic>> pedidos;

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

  void excluirPedido(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Deseja excluir este pedido?'),
          content: Text('Pedido ${index + 1}'),
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
                  widget.pedidos.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedidos Salvos')),
      body: ListView.builder(
        itemCount: widget.pedidos.length,
        itemBuilder: (context, index) {
          String observacao =
              widget.pedidos[index]['observacao'] ?? 'Sem observação';

          return ExpansionTile(
            title: Text('Pedido ${index + 1}'),
            initiallyExpanded: _expandidos[index],
            onExpansionChanged: (expanded) {
              setState(() {
                _expandidos[index] = expanded;
              });
            },
            children: [
              ...widget.pedidos[index]['itens']
                  .map(
                    (produto) => ListTile(
                      title: Text(
                        "${produto['nome']} - ${produto['peso']}${produto['unidade']} - Qtd: ${produto['quantidade']} - Preço: R\$ ${(produto['preco'] )}",
                      ),
                    ),
                  )
                  .toList(),

              ListTile(
                title: Text(
                  'Observação: $observacao',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              ListTile(
                title: Text('Gerar PDF'),
                leading: Icon(Icons.picture_as_pdf, color: Colors.blue),
                onTap:
                    () =>
                        PdfGenerator.generatePdf(widget.pedidos[index], index),
              ),
              ListTile(
                title: Text('Excluir Pedido'),
                leading: Icon(Icons.delete, color: Colors.red),
                onTap: () => excluirPedido(index),
              ),
            ],
          );
        },
      ),
    );
  }
}
