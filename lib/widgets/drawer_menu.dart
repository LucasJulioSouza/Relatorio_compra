import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  final VoidCallback onAdicionarProduto;
  final VoidCallback onAdicionarFornecedor;

  const DrawerMenu({
    required this.onAdicionarProduto,
    required this.onAdicionarFornecedor,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text('Menu', style: TextStyle(fontSize: 24)),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: Icon(Icons.add_box),
            title: Text('Adicionar Produto'),
            onTap: () {
              Navigator.pop(context);
              onAdicionarProduto();
            },
          ),
          ListTile(
            leading: Icon(Icons.store),
            title: Text('Adicionar Fornecedor'),
            onTap: () {
              Navigator.pop(context);
              onAdicionarFornecedor();
            },
          ),
        ],
      ),
    );
  }
}
