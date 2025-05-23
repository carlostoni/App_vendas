import 'package:flutter/material.dart';
import '../Pdf/pdf_generator.dart';

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
          backgroundColor: Colors.white,
          title: Text('Deseja excluir este pedido?'),
          content: Text('Pedido ${index + 1}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar', style: TextStyle(color: Colors.black),),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.pedidos.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Excluir', style: TextStyle(color: Colors.red),),
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
        title: Text(
          'Pedidos Salvos',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.pedidos.length,
        itemBuilder: (context, index) {
          String observacao =
              widget.pedidos[index]['observacao'] ?? 'Sem observação';

          final totalPedido = (widget.pedidos[index]['itens'] as List)
              .fold<double>(0.0, (double soma, dynamic produto) {
                final int quantidade = produto['quantidade'] ?? 0;
                final double preco = (produto['preco'] ?? 0).toDouble();
                return soma + (quantidade * preco);
              });

          return ExpansionTile(
            title: Text(
              'Pedido  ${index + 1}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            initiallyExpanded: _expandidos[index],
            onExpansionChanged: (expanded) {
              setState(() {
                _expandidos[index] = expanded;
              });
            },
            children: [
              ...widget.pedidos[index]['itens'].map<Widget>((produto) {
                final int quantidade = produto['quantidade'];
                final double preco = (produto['preco'] ?? 0).toDouble();
                final double total = quantidade * preco;

                return ListTile(
                  title: Text(
                    "${produto['nome']} - ${produto['peso']}${produto['unidade']} - "
                    "Qtd: $quantidade - Preço: R\$ ${preco.toStringAsFixed(2)} - "
                    "Total: R\$ ${total.toStringAsFixed(2)}",
                  ),
                );
              }).toList(),

              ListTile(
                title: Text(
                  'Total do Pedido: R\$ ${totalPedido.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              ListTile(
                title: Text(
                  'Observação: $observacao',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gerando PDF...')),
                        );
                        await PdfGenerator.generatePdf(
                          widget.pedidos[index],
                          index,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('PDF gerado com sucesso!')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf, color: Colors.blue),
                            SizedBox(width: 20),
                            Text('Gerar PDF'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => excluirPedido(index),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 20),
                            Text('Excluir Pedido'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
