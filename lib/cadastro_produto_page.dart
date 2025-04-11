import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<String> categorias = ['Alimentos'];
  final List<String> unidades = ['g', 'kg', 'ml', 'un'];

  String categoriaSelecionada = 'Alimentos';
  String unidadeSelecionada = 'g';

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    final listaSalva = prefs.getStringList('categorias');
    setState(() {
      categorias = listaSalva ?? ['Alimentos'];
      categoriaSelecionada = categorias.first;
    });
  }

  Future<void> _salvarCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categorias', categorias);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Produto',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nomeController, 'Nome do Produto'),
            _buildPesoVolumeField(),
            _buildPrecoField(),
            _buildTextField(_quantidadeController, 'Quantidade', isNumeric: true),
            _buildCategoriaDropdown(),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _salvarProduto,
               style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, 
                foregroundColor: Colors.black, 
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),

                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold ),
              ),
              
              child: const Text('Salvar', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false, bool isDecimal = false}) {
    return TextField(
      controller: controller,
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : isNumeric
              ? TextInputType.number
              : TextInputType.text,
      inputFormatters: isDecimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d{0,2}'))]
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

  Widget _buildPrecoField() {
    return Row(
      children: [
        const Text('R\$'),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTextField(
            _precoController,
            'Preço',
            isDecimal: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriaDropdown() {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            value: categoriaSelecionada,
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() => categoriaSelecionada = newValue);
              }
            },
            items: categorias
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _mostrarDialogoNovaCategoria,
        ),
      ],
    );
  }

  void _mostrarDialogoNovaCategoria() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Categoria'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Digite o nome da categoria'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final novaCategoria = controller.text.trim();
              if (novaCategoria.isNotEmpty && !categorias.contains(novaCategoria)) {
                setState(() {
                  categorias.add(novaCategoria);
                  categoriaSelecionada = novaCategoria;
                });
                await _salvarCategorias();
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
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
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.')) ?? 0.0;
    final preco = double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0;
    final quantidade = int.tryParse(_quantidadeController.text) ?? 1;

    widget.onSalvar(nome, peso, quantidade, preco, categoriaSelecionada, unidadeSelecionada);
    Navigator.pop(context);
  }
}
