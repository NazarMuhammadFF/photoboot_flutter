import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/printer_service.dart';

class PrinterProvider with ChangeNotifier {
  final PrinterService _printerService = PrinterService();
  List<Printer> _printers = [];
  Printer? _selectedPrinter;

  List<Printer> get printers => _printers;
  Printer? get selectedPrinter => _selectedPrinter;

  Future<void> loadPrinters() async {
    _printers = await _printerService.getPrinters();
    if (_printers.isNotEmpty) {
      _selectedPrinter = _printers.first;
    }
    notifyListeners();
  }

  void selectPrinter(Printer printer) {
    _selectedPrinter = printer;
    notifyListeners();
  }

  Future<void> printImage(Uint8List imageBytes) async {
    if (_selectedPrinter != null) {
      await _printerService.printToSpecificPrinter(
        _selectedPrinter!,
        imageBytes,
      );
    } else {
      await _printerService.printImage(imageBytes);
    }
  }
}
