import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generatePdf(Map<String, dynamic> pedido, int index) async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final headers = ['Nº', 'Produto', 'Peso/Unidade', 'Qtd', 'Preço', 'Total'];
    final itens = pedido['itens'] as List;

    final dataRows = List<pw.TableRow>.generate(itens.length, (i) {
      final produto = itens[i];
      final int quantidade = produto['quantidade'] ?? 0;
      final double preco = (produto['preco'] ?? 0).toDouble();
      final double total = quantidade * preco;

      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text('${i + 1}', style: pw.TextStyle(font: ttf)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(produto['nome'] ?? '', style: pw.TextStyle(font: ttf)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text('${produto['peso']}${produto['unidade']}', style: pw.TextStyle(font: ttf)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text('$quantidade', style: pw.TextStyle(font: ttf)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text('R\$ ${preco.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text('R\$ ${total.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf)),
          ),
        ],
      );
    });

    final double totalPedido = itens.fold<double>(
      0.0,
      (soma, item) {
        final qtd = item['quantidade'] ?? 0;
        final preco = (item['preco'] ?? 0).toDouble();
        return soma + (qtd * preco);
      },
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Pedido ${index + 1}',
              style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: headers.map((header) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
              ...dataRows,
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Text('Total do Pedido: R\$ ${totalPedido.toStringAsFixed(2)}',
              style: pw.TextStyle(font: ttf, fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Observação: ${pedido['observacao'] ?? 'Sem observação'}',
              style: pw.TextStyle(font: ttf, fontStyle: pw.FontStyle.italic)),
        ],
      ),
    );

    // Mostra o diálogo do sistema para salvar/imprimir PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
