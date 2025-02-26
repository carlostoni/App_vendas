import 'package:flutter/material.dart';

class CadastroProdutoPage extends StatefulWidget {
  final Function(String, double, int, String, String) onSalvar;

  CadastroProdutoPage({required this.onSalvar});

  @override
  _CadastroProdutoPageState createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final List<String> categorias = ['Alimentos', 'Vestuário', 'Eletrodomésticos', 'Móveis'];
  final List<String> unidades = ['g', 'kg', 'ml'];

  String categoriaSelecionada = 'Alimentos';
  String unidadeSelecionada = 'g';

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pesoController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Peso/Volume'),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: unidadeSelecionada,
                  onChanged: (String? newValue) {
                    setState(() {
                      unidadeSelecionada = newValue!;
                    });
                  },
                  items: unidades.map<DropdownMenuItem<String>>((String unidade) {
                    return DropdownMenuItem<String>(
                      value: unidade,
                      child: Text(unidade),
                    );
                  }).toList(),
                ),
              ],
            ),
            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantidade'),
            ),
            DropdownButton<String>(
              value: categoriaSelecionada,
              onChanged: (String? newValue) {
                setState(() {
                  categoriaSelecionada = newValue!;
                });
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
                widget.onSalvar(nome, peso, quantidade, categoriaSelecionada, unidadeSelecionada);
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
