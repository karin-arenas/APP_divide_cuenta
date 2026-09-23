import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/event_draft.dart';
import '../models/receipt_item.dart';
import '../services/gemini_ocr_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'event_correction_table_screen.dart';
import 'settings_screen.dart';

/// Pantalla para tomar/elegir la foto de la boleta, recortarla para que
/// Gemini se enfoque solo en la boleta (sin fondo) y mandarla a Gemini
/// para OCR. Si no hay clave API configurada, o si el OCR falla, se puede
/// seguir en modo 100% manual.
class EventOcrCaptureScreen extends StatefulWidget {
  final EventDraft draft;
  const EventOcrCaptureScreen({super.key, required this.draft});

  @override
  State<EventOcrCaptureScreen> createState() => _EventOcrCaptureScreenState();
}

class _EventOcrCaptureScreenState extends State<EventOcrCaptureScreen> {
  static const _loadingMessages = [
    'Leyendo boleta con Gemini...',
    'Detectando los ítems...',
    'Reconociendo precios...',
    'Ordenando cantidades y totales...',
    'Casi listo, un momento más...',
  ];

  final _picker = ImagePicker();
  final _ocrService = GeminiOcrService();
  final _settings = SettingsService();
  File? _image;
  bool _processing = false;
  int _loadingMessageIndex = 0;
  Timer? _loadingMessageTimer;

  @override
  void dispose() {
    _loadingMessageTimer?.cancel();
    super.dispose();
  }

  void _startLoadingMessages() {
    _loadingMessageIndex = 0;
    _loadingMessageTimer?.cancel();
    _loadingMessageTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _loadingMessageIndex =
            (_loadingMessageIndex + 1) % _loadingMessages.length;
      });
    });
  }

  void _stopLoadingMessages() {
    _loadingMessageTimer?.cancel();
    _loadingMessageTimer = null;
  }

  Future<void> _pickImage(ImageSource source) async {
    final xfile = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2000,
    );
    if (xfile == null) return;

    // Deja que el usuario recorte la foto para dejar solo la boleta,
    // sacando la mesa/fondo/manos, lo que ayuda a que Gemini lea mejor
    // y que la imagen final pese menos (sube más rápido).
    final cropped = await ImageCropper().cropImage(
      sourcePath: xfile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recorta la boleta',
          toolbarColor: AppTheme.surface,
          toolbarWidgetColor: AppTheme.onSurface,
          backgroundColor: AppTheme.surface,
          activeControlsWidgetColor: AppTheme.secondary,
          statusBarColor: AppTheme.surface,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Recorta la boleta',
        ),
      ],
    );
    if (cropped == null) return; // el usuario canceló el recorte

    setState(() => _image = File(cropped.path));
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
    _startLoadingMessages();
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
      _stopLoadingMessages();
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
            onPressed: () {
              Navigator.pop(ctx);
              _runOcr();
            },
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
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _loadingMessages[_loadingMessageIndex],
                              key: ValueKey(_loadingMessageIndex),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.onSurfaceVariant),
                            ),
                          ),
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
