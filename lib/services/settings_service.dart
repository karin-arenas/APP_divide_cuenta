import 'package:shared_preferences/shared_preferences.dart';

/// Configuración local de la app (clave API de Gemini, etc). Guardada con
/// shared_preferences en el dispositivo del usuario; nunca se envía a
/// ningún servidor propio, sólo directamente a la API de Google cuando el
/// propio usuario dispara el OCR.
class SettingsService {
  static const _keyGeminiApiKey = 'gemini_api_key';

  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_keyGeminiApiKey);
    if (key == null || key.trim().isEmpty) return null;
    return key.trim();
  }

  Future<void> setGeminiApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGeminiApiKey, key.trim());
  }

  Future<void> clearGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGeminiApiKey);
  }
}
