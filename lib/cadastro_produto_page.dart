import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CadastroProdutoPage extends StatefulWidget {
  final Function(String, double, int, double, String, String) onSalvar;

  const CadastroProdutoPage({Key? key, required this.onSalvar}) : super(key: key);

  @override
  _CadastroProdutoPageState createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final _nomeController = TextEditingController();
  final _pesoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();

  final List<String> categorias = ['Alimentos', 'Vestuário', 'Eletrodomésticos', 'Móveis'];
  final List<String> unidades = ['g', 'kg', 'ml'];

  String categoriaSelecionada = 'Alimentos';
  String unidadeSelecionada = 'g';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Produto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nomeController, 'Nome do Produto'),
            _buildPesoVolumeField(),
            _buildTextField(_quantidadeController, 'Quantidade', isNumeric: true),
            _buildTextField(_precoController, 'Preço', isDecimal: true),
            _buildDropdown(categorias, categoriaSelecionada, (newValue) {
              setState(() => categoriaSelecionada = newValue);
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _salvarProduto,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false, bool isDecimal = false}) {
    return TextField(
      controller: controller,
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : isNumeric
              ? TextInputType.number
              : TextInputType.text,
      inputFormatters: isDecimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
          : null,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildPesoVolumeField() {
    return Row(
      children: [
        Expanded(child: _buildTextField(_pesoController, 'Peso/Volume', isNumeric: true)),
        const SizedBox(width: 10),
        _buildDropdown(unidades, unidadeSelecionada, (newValue) {
          setState(() => unidadeSelecionada = newValue);
        }),
      ],
    );
  }

  Widget _buildDropdown(List<String> items, String selectedItem, ValueChanged<String> onChanged) {
    return DropdownButton<String>(
      value: selectedItem,
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
    );
  }

  void _salvarProduto() {
    final nome = _nomeController.text;
    final peso = double.tryParse(_pesoController.text) ?? 0.0;
    final quantidade = int.tryParse(_quantidadeController.text) ?? 1;
    final preco = double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0;

    widget.onSalvar(nome, peso, quantidade, preco, categoriaSelecionada, unidadeSelecionada);
    Navigator.pop(context);
  }
}
