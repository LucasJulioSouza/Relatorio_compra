import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  String produto;

  @HiveField(1)
  String unidade;

  @HiveField(2)
  String fornecedor;

  @HiveField(3)
  int quantidade;

  @HiveField(4)
  double valorUnitario;

  Item(
    this.produto,
    this.unidade,
    this.fornecedor,
    this.quantidade,
    this.valorUnitario,
  );

  double get valorTotal => quantidade * valorUnitario;
}
