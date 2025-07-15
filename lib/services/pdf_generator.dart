import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/item.dart';

Future<void> gerarPDF(List<Item> itens, String titulo) async {
  final pdf = pw.Document();

  final totalGeral = itens.fold<double>(
    0.0,
    (soma, item) => soma + item.valorTotal,
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text(
          titulo,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 16),
        pw.Table.fromTextArray(
          headers: [
            'Produto',
            'Unidade',
            'Fornecedor',
            'Qtd',
            'Valor Unitário',
            'Total',
          ],
          data: [
            ...itens.map(
              (item) => [
                item.produto,
                item.unidade,
                item.fornecedor,
                item.quantidade.toString(),
                'R\$ ${item.valorUnitario.toStringAsFixed(2)}',
                'R\$ ${item.valorTotal.toStringAsFixed(2)}',
              ],
            ),
            [
              '',
              '',
              '',
              '',
              pw.Text(
                'Total Geral:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              'R\$ ${totalGeral.toStringAsFixed(2)}',
            ],
          ],
        ),
      ],
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/relatorio_compras.pdf');
  await file.writeAsBytes(await pdf.save());

  await Share.shareXFiles([XFile(file.path)], text: titulo);
}
