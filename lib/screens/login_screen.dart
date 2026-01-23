import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  // Paleta de Colores
  static const Color _mintProtagonist = Color(0xFF00E0A6);
  static const Color _turquoiseTechnical = Color(0xFF00B7B0);
  static const Color _forestGreenText = Color(0xFF004C3F);
  static const Color _backgroundPale = Color(0xFFF1FBF9); // #F1FBF9
  static const Color _placeholderText = Color(0xFF8BA29F); // #8BA29F
  // Sombra Eco #004C3F al 10%
  static final Color _shadowEco = const Color(
    0xFF004C3F,
  ).withValues(alpha: 0.10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundPale,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Stack(
          children: [
            // Fondo con Gradiente
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    const Color(
                      0xFF00E0A6,
                    ).withValues(alpha: 0.12), // El 'toque' vivo pero suave
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      const Icon(
                        Icons.eco_rounded,
                        size: 80,
                        color: _mintProtagonist,
                      ),
                      const SizedBox(height: 24),

                      // Título
                      Text(
                        'EcoGrid',
                        style: TextStyle(
                          color: _forestGreenText,
                          fontSize: 34, // 34px
                          fontWeight: FontWeight.w800, // ExtraBold
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtítulo
                      Text(
                        'Monitorea tu entorno en tiempo real',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _mintProtagonist,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Card Glass
                      ClipRRect(
                        borderRadius: BorderRadius.circular(26), // 26px
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 15,
                            sigmaY: 15,
                          ), // 15px blur
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.4,
                              ), // 40% alpha
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _shadowEco,
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Campo Email
                                _buildTextField(
                                  label: 'Correo Electrónico',
                                  icon: Icons.email_outlined,
                                  hint: 'ejemplo@ecogrid.com',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),

                                // Campo Contraseña
                                _buildTextField(
                                  label: 'Contraseña',
                                  icon: Icons.lock_outline,
                                  hint: '••••••••',
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: _placeholderText,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Botón Iniciar Sesión
                                Container(
                                  width: double.infinity,
                                  height: 56, // Un poco más alto
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        _mintProtagonist,
                                        _turquoiseTechnical,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      28,
                                    ), // Fully rounded
                                    boxShadow: [
                                      BoxShadow(
                                        color: _mintProtagonist.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        context.go('/app-home');
                                      },
                                      borderRadius: BorderRadius.circular(28),
                                      child: const Center(
                                        child: Text(
                                          'Iniciar sesión',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Link Olvidaste contraseña
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: _forestGreenText,
                                  ),
                                  child: Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(
                                      color: _placeholderText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Crear cuenta
                      GestureDetector(
                        onTap: () {
                          context.push('/register');
                        },
                        child: const Text(
                          'Crear una cuenta nueva',
                          style: TextStyle(
                            color: _mintProtagonist,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '© 2026 EcoGrid Technologies. v1.0.4',
                        style: TextStyle(color: _placeholderText, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    String? hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: _forestGreenText.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26), // Match card radius style
            border: Border.all(
              color: Colors.transparent,
            ), // No border visible in image
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: _forestGreenText,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              prefixIcon: Icon(icon, color: _mintProtagonist),
              suffixIcon: suffixIcon,
              hintText: hint,
              hintStyle: TextStyle(color: _placeholderText, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
