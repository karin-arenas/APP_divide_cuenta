import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/event_draft.dart';
import '../models/receipt_item.dart';
import '../services/gemini_ocr_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'event_correction_table_screen.dart';
import 'settings_screen.dart';

/// Pantalla para tomar/elegir la foto de la boleta y mandarla a Gemini
/// para OCR. Si no hay clave API configurada, o si el OCR falla, se puede
/// seguir en modo 100% manual.
class EventOcrCaptureScreen extends StatefulWidget {
  final EventDraft draft;
  const EventOcrCaptureScreen({super.key, required this.draft});

  @override
  State<EventOcrCaptureScreen> createState() => _EventOcrCaptureScreenState();
}

class _EventOcrCaptureScreenState extends State<EventOcrCaptureScreen> {
  final _picker = ImagePicker();
  final _ocrService = GeminiOcrService();
  final _settings = SettingsService();
  File? _image;
  bool _processing = false;

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (xfile == null) return;
    setState(() => _image = File(xfile.path));
    await _runOcr();
  }

  Future<void> _runOcr() async {
    if (_image == null) return;
    final apiKey = await _settings.getGeminiApiKey();
    if (apiKey == null) {
      if (!mounted) return;
      final goSettings = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Falta la clave API'),
          content: const Text(
              'No has configurado tu clave API de Gemini. Puedes configurarla en Ajustes, o continuar ingresando los ítems manualmente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Ingresar manualmente'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ir a Ajustes'),
            ),
          ],
        ),
      );
      if (goSettings == true) {
        if (!mounted) return;
        await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()));
      } else {
        _goManual();
      }
      return;
    }

    setState(() => _processing = true);
    try {
      final result = await _ocrService.extractFromImage(_image!, apiKey);
      final items = <ReceiptItem>[];
      for (final ocrItem in result.items) {
        items.add(ReceiptItem(
          id: widget.draft.newItemId(),
          eventId: widget.draft.id,
          name: ocrItem.name,
          quantity: ocrItem.quantity,
          unitPrice: ocrItem.unitPrice,
          totalPrice: ocrItem.totalPrice,
        ));
      }
      widget.draft.tipPercent = result.suggestedTipPercent;
      _goToCorrection(items);
    } on GeminiOcrException catch (e) {
      _showError(e.toString());
    } catch (e) {
      _showError('Ocurrió un error inesperado leyendo la boleta: $e');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No se pudo leer la boleta'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Reintentar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _goManual();
            },
            child: const Text('Ingresar manualmente'),
          ),
        ],
      ),
    );
  }

  void _goManual() {
    _goToCorrection([]);
  }

  void _goToCorrection(List<ReceiptItem> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventCorrectionTableScreen(
          draft: widget.draft,
          initialItems: items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foto de la boleta')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          children: [
            Expanded(
              child: Center(
                child: _processing
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Leyendo boleta con Gemini...'),
                        ],
                      )
                    : _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!, fit: BoxFit.contain),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 96, color: AppTheme.onSurfaceVariant),
                              const SizedBox(height: 12),
                              Text(
                                'Toma una foto de la boleta o elige una de la galería.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.onSurfaceVariant),
                              ),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _processing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _processing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _processing ? null : _goManual,
              child: const Text('Prefiero ingresar los ítems manualmente'),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
