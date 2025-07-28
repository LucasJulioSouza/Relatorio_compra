import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hortipraias/screens/editar_item_screem.dart';
import '../models/item.dart';
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

  void _editarItem(int index, Item item) {
    final produtos = produtosBox.values.toList();
    final fornecedores = fornecedoresBox.values.toList();
    final unidades =
        this.unidades; // a lista de unidades já declarada na classe

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarItemScreen(
          index: index,
          item: item,
          onSave: (i, novoItem) {
            itensBox.putAt(i, novoItem); // salva no Hive
            setState(() {});
          },
          produtosDisponiveis: produtos,
          fornecedoresDisponiveis: fornecedores,
          unidadesDisponiveis: unidades,
        ),
      ),
    );
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                labelText: 'Título do Relatório (opcional)',
                prefixIcon: Icon(
                  Icons.description,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _produtoSelecionado,
                        hint: const Text('Selecione o produto'),
                        items: produtos
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _produtoSelecionado = val),
                        validator: (val) =>
                            val == null ? 'Escolha um produto' : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.shopping_basket,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _unidadeSelecionada,
                        hint: const Text('Selecione a unidade'),
                        items: unidades
                            .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _unidadeSelecionada = val),
                        validator: (val) =>
                            val == null ? 'Escolha uma unidade' : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.straighten,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _fornecedorSelecionado,
                        hint: const Text('Selecione o fornecedor'),
                        items: fornecedores
                            .map(
                              (f) => DropdownMenuItem(value: f, child: Text(f)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _fornecedorSelecionado = val),
                        validator: (val) =>
                            val == null ? 'Escolha um fornecedor' : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.local_shipping,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _quantidadeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantidade',
                          prefixIcon: Icon(
                            Icons.format_list_numbered,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Digite a quantidade'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _valorController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Valor unitário (R\$)',
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Digite o valor unitário'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _adicionarItem,
                          child: Text(
                            _itemEditando == null
                                ? 'Adicionar ao Relatório'
                                : 'Salvar Alterações',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Itens do Relatório',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            const Divider(thickness: 2, height: 30),
            ValueListenableBuilder(
              valueListenable: itensBox.listenable(),
              builder: (context, Box<Item> box, _) {
                final itens = box.values.toList();
                return itens.isNotEmpty
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: itens.length,
                        itemBuilder: (context, index) {
                          final item = itens[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red.shade700,
                                child: Text(
                                  item.quantidade.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                item.produto,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${item.unidade} • Fornecedor: ${item.fornecedor}\nValor Unitário: R\$${item.valorUnitario.toStringAsFixed(2)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () => _editarItem(index, item),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _excluirItem(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Text('Nenhum item adicionado ainda.');
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _gerarPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Gerar e Compartilhar PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
