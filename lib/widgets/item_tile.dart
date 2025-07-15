import 'package:flutter/material.dart';
import '../models/item.dart';

class ItemTile extends StatelessWidget {
  final Item item;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const ItemTile({
    Key? key,
    required this.item,
    required this.onEditar,
    required this.onExcluir,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text('${item.quantidade} ${item.unidade} de ${item.produto}'),
        subtitle: Text(
          'Fornecedor: ${item.fornecedor} • R\$ ${item.valorUnitario.toStringAsFixed(2)} cada\nTotal: R\$ ${item.valorTotal.toStringAsFixed(2)}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange),
              onPressed: onEditar,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onExcluir,
            ),
          ],
        ),
      ),
    );
  }
}
