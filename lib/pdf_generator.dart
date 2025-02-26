import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
                style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              ...pedido['itens'].map<pw.Widget>((item) {
                return pw.Text(
                  "${item['nome']} - ${item['peso']}kg - Qtd: ${item['quantidade']}",
                  style: pw.TextStyle(fontSize: 20), // Aumenta o tamanho do texto dos itens
                );
              }).toList(),
              pw.SizedBox(height: 20),
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
