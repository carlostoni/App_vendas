import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PdfGenerator {
  static Future<void> generatePdf(Map<String, dynamic> pedido, int index) async {
    final pdf = pw.Document();
    final observacao = pedido['observacao'] ?? 'Sem observação';

    // Cálculo do total geral
    final double totalPedido = (pedido['itens'] as List).fold<double>(
      0.0,
      (double soma, item) =>
          soma + (item['quantidade'] * (item['preco'] ?? 0).toDouble()),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Pedido ${index + 1}',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              // Tabela com total por item
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1),
                  4: pw.FlexColumnWidth(1), // Coluna do total
                },
                children: [
                  // Cabeçalho
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Produto', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Peso', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Qtd', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Preço', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(5),
                        child: pw.Text('Total', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),

                  // Linhas da tabela
                  ...pedido['itens'].map<pw.TableRow>((item) {
                    final int qtd = item['quantidade'] ?? 0;
                    final double preco = (item['preco'] ?? 0).toDouble();
                    final double total = qtd * preco;

                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(item['nome'], style: pw.TextStyle(fontSize: 14)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text("${item['peso']}${item['unidade']}", style: pw.TextStyle(fontSize: 14)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text("$qtd", style: pw.TextStyle(fontSize: 14)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text("R\$ ${preco.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 14)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text("R\$ ${total.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 14)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 10),

              // Total geral do pedido
              pw.Text(
                'Total do Pedido: R\$ ${totalPedido.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),

              pw.SizedBox(height: 10),

              // Observação
              pw.Text(
                'Observação: $observacao',
                style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
