import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CadastroProdutoPage extends StatefulWidget {
  final Function(String, double, int, double, String, String) onSalvar;

  CadastroProdutoPage({required this.onSalvar});

  @override
  _CadastroProdutoPageState createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final List<String> categorias = [
    'Alimentos',
    'Vestuário',
    'Eletrodomésticos',
    'Móveis',
  ];
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
                  items:
                      unidades.map<DropdownMenuItem<String>>((String unidade) {
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
            TextField(
              controller: _precoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(labelText: 'Preço'),
            ),
            DropdownButton<String>(
              value: categoriaSelecionada,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    categoriaSelecionada = newValue;
                  });
                }
              },

              items:
                  categorias.map<DropdownMenuItem<String>>((String categoria) {
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
                final quantidade =
                    int.tryParse(_quantidadeController.text) ?? 1;
                final preco = double.tryParse(_precoController.text.replaceAll(',', '.'),) ?? 0.0;
                widget.onSalvar(
                  nome,
                  peso,
                  quantidade,
                  preco,
                  categoriaSelecionada,
                  unidadeSelecionada,
                );
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
