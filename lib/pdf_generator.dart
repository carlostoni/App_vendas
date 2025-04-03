import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class PdfGenerator {
  static Future<void> generatePdf(Map<String, dynamic> pedido, int index) async {
    final pdf = pw.Document();
    final observacao = pedido['observacao'] ?? 'Sem observação';

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

              // Criando a tabela
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(3), // Nome maior
                  1: pw.FlexColumnWidth(1), // Peso menor
                  2: pw.FlexColumnWidth(1), // Quantidade menor
                  3: pw.FlexColumnWidth(1), // Preco
                  
                },
                children: [
                  // Cabeçalho da tabela
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
                    ],
                  ),
                  
                  // Adicionando os itens do pedido na tabela
                  ...pedido['itens'].map<pw.TableRow>((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text(item['nome' ], style: pw.TextStyle(fontSize: 14)),
                        ),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(5),
                            child: pw.Text("${item['peso']}${item['unidade']}", style: pw.TextStyle(fontSize: 14)),
                          ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text("${item['quantidade']}", style: pw.TextStyle(fontSize: 14)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(5),
                          child: pw.Text("${item['preco']}", style: pw.TextStyle(fontSize: 14)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
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
