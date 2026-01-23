import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 🎨 PALETA DE COLORES OBLIGATORIA (Eco-Tech)
const Color _primary = Color(0xFF18C6B3);
const Color _primaryDark = Color(0xFF0FAE9C);
const Color _mintLight = Color(0xFFDFF7F2);
const Color _textPrimary = Color(0xFF0F3D36);
const Color _borderColor = Color(0xFFBFEDE4);
const Color _errorColor = Color(0xFFE57373); // Soft red for errors

/// Muestra el modal de confirmación de cierre de sesión.
void showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: _textPrimary.withValues(alpha: 0.1),
    builder: (ctx) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: const _LogoutConfirmationDialog(),
      ),
    ),
  );
}

class _LogoutConfirmationDialog extends StatefulWidget {
  const _LogoutConfirmationDialog();

  @override
  State<_LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<_LogoutConfirmationDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Invalidate session on server (Simulation)
      // In a real scenario, use your actual backend URL and token
      // final response = await http.post(
      //   Uri.parse('https://api.ecogrid.com/auth/logout'),
      //   headers: {'Authorization': 'Bearer $token'},
      // );
      
      // Simulating API latency and success
      await Future.delayed(const Duration(seconds: 1)); 

      // 2. Remove local tokens and data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clears all data including tokens, user profile, etc.
      // Alternatively, remove specific keys:
      // await prefs.remove('auth_token');
      // await prefs.remove('user_data');

      // 3. Reset app state (if using Provider/Riverpod, do it here)
      // Example: context.read<AuthProvider>().logout();

      if (mounted) {
        // 4. Redirect to Login
        Navigator.of(context).pop(); // Close dialog
        context.go('/login'); // Use GoRouter to replace stack
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cerrar sesión. Verifica tu conexión.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85), // Glass overlay base
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: _textPrimary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: _mintLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isLoading ? Icons.hourglass_empty_rounded : Icons.logout_rounded,
              color: _primaryDark,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            _isLoading ? 'Cerrando sesión...' : '¿Cerrar sesión?',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description or Error
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _errorColor,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              _isLoading
                  ? 'Por favor espera un momento.'
                  : '¿Estás seguro de que deseas salir del sistema?',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _textPrimary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 32),

          // Primary Button (Gradient)
          if (!_isLoading) ...[
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, _primaryDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleLogout,
                  borderRadius: BorderRadius.circular(50),
                  child: Center(
                    child: Text(
                      'Sí, cerrar sesión',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Secondary Button (Outline)
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: _borderColor),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(50),
                  child: Center(
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Loading Indicator
            const SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primary),
                strokeWidth: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
