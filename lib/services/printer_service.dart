import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrinterService {
  Future<void> printImage(Uint8List imageBytes) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(pw.MemoryImage(imageBytes)));
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<List<Printer>> getPrinters() async {
    return await Printing.listPrinters();
  }

  Future<void> printToSpecificPrinter(
    Printer printer,
    Uint8List imageBytes,
  ) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(pw.MemoryImage(imageBytes)));
        },
      ),
    );

    await Printing.directPrintPdf(
      printer: printer,
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}
