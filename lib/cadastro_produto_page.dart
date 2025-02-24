// cadastro_produto_page.dart
import 'package:flutter/material.dart';

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
              decoration: InputDecoration(labelText: 'Peso (g)'),
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
