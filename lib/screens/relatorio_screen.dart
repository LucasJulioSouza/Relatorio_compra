import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/item.dart';
import '../widgets/item_tile.dart';
import '../widgets/drawer_menu.dart';
import '../services/pdf_generator.dart';

class RelatorioScreen extends StatefulWidget {
  @override
  _RelatorioScreenState createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _valorController = TextEditingController();
  final _tituloController = TextEditingController(text: 'Relatório de Compras');

  String? _produtoSelecionado;
  String? _unidadeSelecionada;
  String? _fornecedorSelecionado;

  List<String> unidades = ['Maço', 'Caixa', 'Unidade', 'Kg'];

  late Box<Item> itensBox;
  late Box<String> produtosBox;
  late Box<String> fornecedoresBox;

  Item? _itemEditando;

  @override
  void initState() {
    super.initState();
    itensBox = Hive.box<Item>('itensBox');
    produtosBox = Hive.box<String>('produtosBox');
    fornecedoresBox = Hive.box<String>('fornecedoresBox');
  }

  void _adicionarItem() {
    if (_formKey.currentState!.validate()) {
      final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
      final valor =
          double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0;

      if (_itemEditando == null) {
        final novoItem = Item(
          _produtoSelecionado!,
          _unidadeSelecionada!,
          _fornecedorSelecionado!,
          quantidade,
          valor,
        );
        itensBox.add(novoItem);
      } else {
        _itemEditando!
          ..produto = _produtoSelecionado!
          ..unidade = _unidadeSelecionada!
          ..fornecedor = _fornecedorSelecionado!
          ..quantidade = quantidade
          ..valorUnitario = valor;
        _itemEditando!.save();
      }

      _limparFormulario();
    }
  }

  void _editarItem(Item item) {
    setState(() {
      _itemEditando = item;
      _produtoSelecionado = item.produto;
      _unidadeSelecionada = item.unidade;
      _fornecedorSelecionado = item.fornecedor;
      _quantidadeController.text = item.quantidade.toString();
      _valorController.text = item.valorUnitario.toStringAsFixed(2);
    });
  }

  void _excluirItem(Item item) async {
    await item.delete();
    setState(() {});
  }

  void _limparFormulario() {
    _itemEditando = null;
    _produtoSelecionado = null;
    _unidadeSelecionada = null;
    _fornecedorSelecionado = null;
    _quantidadeController.clear();
    _valorController.clear();
    setState(() {});
  }

  Future<void> _gerarPDF() async {
    final titulo = _tituloController.text.trim().isEmpty
        ? 'Relatório de Compras'
        : _tituloController.text.trim();

    final itens = itensBox.values.toList();
    await gerarPDF(itens, titulo);
  }

  void _adicionarNovoProduto() async {
    String? novoProduto = await _mostrarDialogoAdicionar('produto');
    if (novoProduto != null && novoProduto.trim().isNotEmpty) {
      produtosBox.add(novoProduto.trim());
      setState(() {});
    }
  }

  void _adicionarNovoFornecedor() async {
    String? novoFornecedor = await _mostrarDialogoAdicionar('fornecedor');
    if (novoFornecedor != null && novoFornecedor.trim().isNotEmpty) {
      fornecedoresBox.add(novoFornecedor.trim());
      setState(() {});
    }
  }

  Future<String?> _mostrarDialogoAdicionar(String tipo) async {
    TextEditingController _controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar novo $tipo'),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(labelText: 'Nome do $tipo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _controller.text),
            child: Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produtos = produtosBox.values.toList();
    final fornecedores = fornecedoresBox.values.toList();

    return Scaffold(
      appBar: AppBar(title: Text('Relatório de Compras')),
      drawer: DrawerMenu(
        onAdicionarProduto: _adicionarNovoProduto,
        onAdicionarFornecedor: _adicionarNovoFornecedor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título do Relatório (opcional)',
              ),
            ),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _produtoSelecionado,
                    hint: Text('Selecione o produto'),
                    items: produtos
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _produtoSelecionado = val),
                    validator: (val) =>
                        val == null ? 'Escolha um produto' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _unidadeSelecionada,
                    hint: Text('Selecione a unidade'),
                    items: unidades
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _unidadeSelecionada = val),
                    validator: (val) =>
                        val == null ? 'Escolha uma unidade' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _fornecedorSelecionado,
                    hint: Text('Selecione o fornecedor'),
                    items: fornecedores
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _fornecedorSelecionado = val),
                    validator: (val) =>
                        val == null ? 'Escolha um fornecedor' : null,
                  ),
                  TextFormField(
                    controller: _quantidadeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Quantidade'),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Digite a quantidade'
                        : null,
                  ),
                  TextFormField(
                    controller: _valorController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Valor unitário (R\$)',
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Digite o valor unitário'
                        : null,
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _adicionarItem,
                    child: Text(
                      _itemEditando == null
                          ? 'Adicionar ao Relatório'
                          : 'Salvar Alterações',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: itensBox.listenable(),
              builder: (context, Box<Item> box, _) {
                final itens = box.values.toList();
                return itens.isNotEmpty
                    ? Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: itens.length,
                            itemBuilder: (context, index) {
                              final item = itens[index];
                              return ItemTile(
                                item: item,
                                onEditar: () => _editarItem(item),
                                onExcluir: () => _excluirItem(item),
                              );
                            },
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _gerarPDF,
                            icon: Icon(Icons.picture_as_pdf),
                            label: Text('Gerar e Compartilhar PDF'),
                          ),
                        ],
                      )
                    : Text('Nenhum item adicionado ainda.');
              },
            ),
          ],
        ),
      ),
    );
  }
}
