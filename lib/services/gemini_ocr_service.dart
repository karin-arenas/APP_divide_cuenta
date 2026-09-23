import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Resultado de la lectura OCR de una boleta.
class OcrItemResult {
  String name;
  double quantity;
  int unitPrice;
  int totalPrice;

  OcrItemResult({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

class OcrResult {
  final List<OcrItemResult> items;
  final int subtotal;
  final double suggestedTipPercent;
  final int total;

  OcrResult({
    required this.items,
    required this.subtotal,
    required this.suggestedTipPercent,
    required this.total,
  });
}

class GeminiOcrException implements Exception {
  final String message;
  GeminiOcrException(this.message);
  @override
  String toString() => message;
}

/// Servicio que envía la foto de la boleta a la API Gemini (Google) para
/// extraer los ítems en formato JSON estructurado.
///
/// La imagen se envía directamente desde el teléfono del usuario al
/// endpoint de Google usando su propia API key (nunca pasa por un servidor
/// propio de esta app).
class GeminiOcrService {
  static const _model = 'gemini-3.6-flash';

  static const _prompt = '''
Eres un sistema de lectura de boletas/recibos de restorán en Chile (pesos chilenos, CLP, sin decimales).
Analiza la imagen adjunta de una boleta y devuelve EXCLUSIVAMENTE un JSON válido, sin texto adicional,
sin explicaciones y sin bloques de markdown (nada de ```), con esta forma exacta:

{"items":[{"name":"nombre del item","quantity":1,"unit_price":0,"total_price":0}],"subtotal":0,"suggested_tip_percent":10,"total":0}

Reglas:
- "quantity" es la cantidad del ítem (si la línea dice "4 Papas de la Casa 20.000", quantity=4, unit_price=5000, total_price=20000).
- Todos los montos son números enteros en pesos chilenos, SIN puntos, SIN comas, SIN símbolo \$.
- Si no puedes leer un campo con certeza, usa tu mejor estimación en base a los demás valores (total = unit_price * quantity).
- "suggested_tip_percent" es el porcentaje de propina sugerida si aparece impreso (ej "PROPINA SUGERIDA 10%" => 10). Si no aparece, usa 10.
- "subtotal" es la suma de los ítems antes de propina. "total" es el total de la boleta (con o sin propina, el que esté impreso como total).
- No agregues ningún campo extra. No agregues comentarios. Responde solo con el JSON.
''';

  /// Prueba rápida de conexión: manda un prompt mínimo (sin imagen) a
  /// Gemini para validar que la clave API es correcta y responde. Se usa
  /// en Ajustes con el botón "Probar Conexión".
  Future<void> testApiKey(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      throw GeminiOcrException('Ingresa una clave API primero.');
    }
    final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey');
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': 'Responde solo con la palabra: ok'}
          ]
        }
      ],
      'generationConfig': {'temperature': 0, 'maxOutputTokens': 8},
    });

    http.Response response;
    try {
      response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 20));
    } on SocketException {
      throw GeminiOcrException('Sin conexión a internet.');
    } catch (e) {
      throw GeminiOcrException('Error de red al contactar a Gemini: $e');
    }

    if (response.statusCode != 200) {
      String detail = response.body;
      try {
        final decoded = jsonDecode(response.body);
        detail = decoded['error']?['message']?.toString() ?? response.body;
      } catch (_) {}
      throw GeminiOcrException(
          'Clave inválida o error de Gemini (${response.statusCode}): $detail');
    }
  }

  Future<OcrResult> extractFromImage(File imageFile, String apiKey) async {
    if (apiKey.trim().isEmpty) {
      throw GeminiOcrException(
          'No hay una clave API de Gemini configurada. Ve a Ajustes para ingresarla.');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mimeType = _guessMimeType(imageFile.path);

    final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey');

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': _prompt},
            {
              'inline_data': {'mime_type': mimeType, 'data': base64Image}
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
      }
    });

    http.Response response;
    try {
      response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 75));
    } on SocketException {
      throw GeminiOcrException(
          'Sin conexión a internet. Revisa tu conexión e intenta de nuevo, o ingresa los ítems manualmente.');
    } catch (e) {
      throw GeminiOcrException('Error de red al contactar a Gemini: $e');
    }

    if (response.statusCode != 200) {
      String detail = response.body;
      try {
        final decoded = jsonDecode(response.body);
        detail = decoded['error']?['message']?.toString() ?? response.body;
      } catch (_) {}
      throw GeminiOcrException(
          'Gemini respondió con error (${response.statusCode}): $detail');
    }

    late Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw GeminiOcrException('Respuesta inválida de Gemini (no es JSON).');
    }

    String? text;
    try {
      final candidates = decoded['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        final blockReason = decoded['promptFeedback']?['blockReason'];
        throw GeminiOcrException(
            'Gemini no devolvió resultados${blockReason != null ? " ($blockReason)" : ""}.');
      }
      final parts = candidates[0]['content']['parts'] as List;
      text = parts.map((p) => p['text'] ?? '').join('\n');
    } catch (e) {
      if (e is GeminiOcrException) rethrow;
      throw GeminiOcrException('No se pudo interpretar la respuesta de Gemini.');
    }

    final cleaned = _stripMarkdownFences(text ?? '');
    Map<String, dynamic> json;
    try {
      json = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw GeminiOcrException(
          'Gemini no devolvió un JSON válido. Puedes intentar de nuevo o ingresar los ítems manualmente.');
    }

    return _parseOcrJson(json);
  }

  String _stripMarkdownFences(String text) {
    var t = text.trim();
    if (t.startsWith('```')) {
      // elimina la primera línea (```json o ```)
      final firstNewline = t.indexOf('\n');
      if (firstNewline != -1) t = t.substring(firstNewline + 1);
      if (t.endsWith('```')) t = t.substring(0, t.length - 3);
    }
    return t.trim();
  }

  OcrResult _parseOcrJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? [];
    final items = rawItems.map((raw) {
      final m = raw as Map<String, dynamic>;
      final quantity = _toDouble(m['quantity']) ?? 1;
      final unitPrice = _toInt(m['unit_price']) ?? 0;
      var totalPrice = _toInt(m['total_price']);
      totalPrice ??= (unitPrice * quantity).round();
      return OcrItemResult(
        name: (m['name'] ?? 'Ítem').toString(),
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
      );
    }).toList();

    final subtotal = _toInt(json['subtotal']) ??
        items.fold<int>(0, (a, b) => a + b.totalPrice);
    final tipPercent = _toDouble(json['suggested_tip_percent']) ?? 10;
    final total = _toInt(json['total']) ?? subtotal;

    if (items.isEmpty) {
      throw GeminiOcrException(
          'No se detectaron ítems en la boleta. Intenta con una foto más nítida o ingresa los ítems manualmente.');
    }

    return OcrResult(
      items: items,
      subtotal: subtotal,
      suggestedTipPercent: tipPercent,
      total: total,
    );
  }

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9.\-]'), '');
      return double.tryParse(cleaned)?.round();
    }
    return null;
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.'));
    return null;
  }

  String _guessMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
