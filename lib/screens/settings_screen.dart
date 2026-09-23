import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../db/db_helper.dart';
import '../services/gemini_ocr_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_header_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService();
  final _ocrService = GeminiOcrService();
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _loading = true;
  bool _saved = false;
  bool _testing = false;
  bool? _testOk;
  String? _testError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = await _settings.getGeminiApiKey();
    setState(() {
      _controller.text = key ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    await _settings.setGeminiApiKey(_controller.text);
    setState(() => _saved = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clave API guardada.')),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testOk = null;
      _testError = null;
    });
    try {
      await _ocrService.testApiKey(_controller.text);
      if (!mounted) return;
      setState(() => _testOk = true);
    } on GeminiOcrException catch (e) {
      if (!mounted) return;
      setState(() {
        _testOk = false;
        _testError = e.toString();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testOk = false;
        _testError = 'Error inesperado: $e';
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar todos los datos'),
        content: const Text(
            'Esto eliminará todo el historial de eventos y la lista de personas guardadas de este dispositivo. Esta acción no se puede deshacer. ¿Continuar?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await DbHelper.instance.clearAllData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todos los datos locales fueron eliminados.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderBar(subtitle: 'Configuración de API'),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Clave API de Gemini',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Se usa para leer automáticamente las boletas por foto. '
                  'Se guarda sólo en este dispositivo y se envía únicamente '
                  'a Google (Gemini) cuando tomas o eliges una foto de boleta.',
                  style: TextStyle(color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  obscureText: _obscure,
                  style: AppTheme.moneyStyle(fontSize: 14, color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Gemini API key',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  onChanged: (_) => setState(() {
                    _saved = false;
                    _testOk = null;
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Guardar clave'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _testing ? null : _testConnection,
                        icon: _testing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.wifi_tethering),
                        label: const Text('Probar conexión'),
                      ),
                    ),
                  ],
                ),
                if (_testOk == true)
                  _StatusBanner(
                    icon: Icons.check_circle_outline,
                    color: AppTheme.success,
                    message: 'Conexión exitosa: la clave funciona.',
                  ),
                if (_testOk == false)
                  _StatusBanner(
                    icon: Icons.error_outline,
                    color: AppTheme.error,
                    message: _testError ?? 'No se pudo validar la clave.',
                  ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => launchUrl(
                    Uri.parse('https://aistudio.google.com/apikey'),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Obtener una clave gratis en aistudio.google.com/apikey',
                      style: TextStyle(
                        color: AppTheme.secondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 40),
                Text('Datos locales', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Todos tus eventos y personas guardadas viven sólo en este '
                  'teléfono. No se sincronizan a ninguna nube.',
                  style: TextStyle(color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _clearAllData,
                  icon: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                  label: const Text('Borrar todo el historial y personas',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _StatusBanner(
      {required this.icon, required this.color, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
