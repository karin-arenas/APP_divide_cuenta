import 'dart:io';

import 'package:excel/excel.dart' as xls;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/evento.dart';
import '../models/person.dart';
import '../models/split_result.dart';

/// Genera el archivo .xlsx con el desglose final de un evento, con formato:
/// encabezado en negrita/color, montos con separador de miles estilo
/// chileno ($11.550), fila de "Consumo" y fila de "Total más propina" en
/// negrita, columnas auto-ajustadas.
class ExcelExportService {
  final _clFormat = NumberFormat.decimalPattern('es_CL');

  String _money(int value) => '\$${_clFormat.format(value)}';

  Future<File> export({
    required Evento evento,
    required List<Person> participants,
    required EventBreakdown breakdown,
  }) async {
    final excel = xls.Excel.createExcel();
    final sheetName = 'Detalle';
    excel.rename(excel.getDefaultSheet()!, sheetName);
    final sheet = excel[sheetName];

    final headerStyle = xls.CellStyle(
      bold: true,
      fontColorHex: xls.ExcelColor.white,
      backgroundColorHex: xls.ExcelColor.fromHexString('#2E7D32'),
      horizontalAlign: xls.HorizontalAlign.Center,
    );
    final boldStyle = xls.CellStyle(bold: true);
    final boldRightStyle = xls.CellStyle(
      bold: true,
      horizontalAlign: xls.HorizontalAlign.Right,
    );
    final rightStyle = xls.CellStyle(horizontalAlign: xls.HorizontalAlign.Right);
    final totalRowStyle = xls.CellStyle(
      bold: true,
      backgroundColorHex: xls.ExcelColor.fromHexString('#C8E6C9'),
      horizontalAlign: xls.HorizontalAlign.Right,
    );
    final totalRowLabelStyle = xls.CellStyle(
      bold: true,
      backgroundColorHex: xls.ExcelColor.fromHexString('#C8E6C9'),
    );

    // Encabezado
    final headers = ['DETALLE', 'TOTAL', ...participants.map((p) => p.name)];
    for (var c = 0; c < headers.length; c++) {
      final cell = sheet.cell(
          xls.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
      cell.value = xls.TextCellValue(headers[c]);
      cell.cellStyle = headerStyle;
    }

    var rowIndex = 1;

    // Filas de ítems
    for (final row in breakdown.rows) {
      _setCell(sheet, 0, rowIndex, row.item.name, boldStyle: null);
      _setCell(sheet, 1, rowIndex, _money(row.item.totalPrice), style: rightStyle);
      for (var c = 0; c < participants.length; c++) {
        final personId = participants[c].id;
        final amount = row.shares[personId];
        if (amount != null) {
          _setCell(sheet, 2 + c, rowIndex, _money(amount), style: rightStyle);
        }
      }
      rowIndex++;
    }

    // Fila "Consumo"
    _setCell(sheet, 0, rowIndex, 'Consumo', style: boldStyle);
    _setCell(sheet, 1, rowIndex, _money(breakdown.consumoTotal), style: boldRightStyle);
    for (var c = 0; c < participants.length; c++) {
      final personId = participants[c].id;
      _setCell(sheet, 2 + c, rowIndex, _money(breakdown.consumoPorPersona[personId] ?? 0),
          style: boldRightStyle);
    }
    rowIndex++;

    // Fila "Propina" (informativa)
    if (evento.tipEnabled) {
      _setCell(sheet, 0, rowIndex, 'Propina', style: null);
      _setCell(sheet, 1, rowIndex, _money(breakdown.propinaTotal), style: rightStyle);
      for (var c = 0; c < participants.length; c++) {
        final personId = participants[c].id;
        _setCell(sheet, 2 + c, rowIndex, _money(breakdown.propinaPorPersona[personId] ?? 0),
            style: rightStyle);
      }
      rowIndex++;
    }

    // Fila "Total más propina"
    _setCell(sheet, 0, rowIndex, 'Total más propina', style: totalRowLabelStyle);
    _setCell(sheet, 1, rowIndex, _money(breakdown.totalFinal), style: totalRowStyle);
    for (var c = 0; c < participants.length; c++) {
      final personId = participants[c].id;
      _setCell(sheet, 2 + c, rowIndex, _money(breakdown.totalPorPersona[personId] ?? 0),
          style: totalRowStyle);
    }

    // Auto-ancho aproximado de columnas
    sheet.setColumnWidth(0, 28);
    sheet.setColumnWidth(1, 14);
    for (var c = 0; c < participants.length; c++) {
      sheet.setColumnWidth(2 + c, 14);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('No se pudo generar el archivo Excel.');
    }

    final dir = await _resolveOutputDir();
    final safeName = evento.name.replaceAll(RegExp(r'[^A-Za-z0-9_\- ]'), '').trim();
    final fileName =
        'DivideCuenta_${safeName.isEmpty ? 'evento' : safeName}_${evento.date.substring(0, 10)}.xlsx';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  void _setCell(xls.Sheet sheet, int col, int row, String value,
      {xls.CellStyle? style, xls.CellStyle? boldStyle}) {
    final cell =
        sheet.cell(xls.CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = xls.TextCellValue(value);
    if (style != null) cell.cellStyle = style;
  }

  Future<Directory> _resolveOutputDir() async {
    if (Platform.isAndroid) {
      // Carpeta de Descargas pública del dispositivo (accesible por el
      // usuario y por otras apps, sin necesitar permisos especiales en
      // Android moderno al usar rutas de la propia app o Downloads directa
      // cuando esté disponible).
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        return downloadsDir;
      }
    }
    final dir = await getApplicationDocumentsDirectory();
    return dir;
  }
}
