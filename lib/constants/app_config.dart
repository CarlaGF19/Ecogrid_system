class AppConfig {
  // URL por defecto de la Web App de Google Sheets (termina en /exec).
  // Si se establece un valor no vacío aquí, la app usará Sheets automáticamente
  // cuando no exista 'api_base_url' en SharedPreferences.
  static const String DEFAULT_API_BASE_URL = '';
}