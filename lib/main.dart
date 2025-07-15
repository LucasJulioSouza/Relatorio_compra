import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/item.dart';
import 'screens/relatorio_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ItemAdapter());

  await Hive.openBox<Item>('itensBox');
  await Hive.openBox<String>('produtosBox');
  await Hive.openBox<String>('fornecedoresBox');

  runApp(RelatorioApp());
}

class RelatorioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relatório de Compras',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RelatorioScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
