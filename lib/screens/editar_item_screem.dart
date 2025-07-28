import 'package:flutter/material.dart';
import '../models/item.dart';

class EditarItemScreen extends StatefulWidget {
  final int index;
  final Item item;
  final Function(int, Item) onSave;
  final List<String> produtosDisponiveis;
  final List<String> fornecedoresDisponiveis;
  final List<String> unidadesDisponiveis;

  const EditarItemScreen({
    super.key,
    required this.index,
    required this.item,
    required this.onSave,
    required this.produtosDisponiveis,
    required this.fornecedoresDisponiveis,
    required this.unidadesDisponiveis,
  });

  @override
  State<EditarItemScreen> createState() => _EditarItemScreenState();
}

class _EditarItemScreenState extends State<EditarItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late String produto;
  late String fornecedor;
  late String unidade;
  late TextEditingController quantidadeController;
  late TextEditingController valorController;

  @override
  void initState() {
    super.initState();

    produto = widget.item.produto;
    fornecedor = widget.item.fornecedor;
    unidade = widget.item.unidade;
    quantidadeController = TextEditingController(
      text: widget.item.quantidade.toString(),
    );
    valorController = TextEditingController(
      text: widget.item.valorUnitario.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    quantidadeController.dispose();
    valorController.dispose();
    super.dispose();
  }

  void salvar() {
    if (_formKey.currentState!.validate()) {
      final novoItem = Item(
        produto,
        unidade,
        fornecedor,
        int.parse(quantidadeController.text),
        double.parse(valorController.text.replaceAll(',', '.')),
      );

      widget.onSave(widget.index, novoItem);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: produto,
                items: widget.produtosDisponiveis
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    produto = val!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Produto'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Selecione um produto' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: unidade,
                items: widget.unidadesDisponiveis
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    unidade = val!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Unidade'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Selecione uma unidade' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: fornecedor,
                items: widget.fornecedoresDisponiveis
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    fornecedor = val!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Fornecedor'),
                validator: (val) => val == null || val.isEmpty
                    ? 'Selecione um fornecedor'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: quantidadeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantidade'),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Digite a quantidade';
                  }
                  final n = int.tryParse(val);
                  if (n == null || n <= 0) {
                    return 'Quantidade inválida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor Unitário (R\$)',
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Digite o valor unitário';
                  }
                  final d = double.tryParse(val.replaceAll(',', '.'));
                  if (d == null || d < 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: salvar, child: const Text('Salvar')),
            ],
          ),
        ),
      ),
    );
  }
}
