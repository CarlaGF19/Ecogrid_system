import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  // Paleta de Colores (Consistente con Login)
  static const Color _mintProtagonist = Color(0xFF00E0A6);
  static const Color _turquoiseTechnical = Color(0xFF00B7B0);
  static const Color _forestGreenText = Color(0xFF004C3F);
  static const Color _backgroundPale = Color(0xFFF1FBF9);
  static const Color _placeholderText = Color(0xFF8BA29F);
  // Sombra Eco
  static final Color _shadowEco = const Color(
    0xFF004C3F,
  ).withValues(alpha: 0.10);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundPale,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _forestGreenText),
          onPressed: () => context.go('/login'), // Vuelve al login
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo con Gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  const Color(0xFF00E0A6).withValues(alpha: 0.12),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Crear cuenta',
                      style: TextStyle(
                        color: _forestGreenText,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtítulo
                    Text(
                      'Crea tu cuenta para acceder al dashboard de EcoGrid',
                      style: TextStyle(
                        color: _mintProtagonist,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Card Glass
                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
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
                              // Nombre Completo
                              _buildTextField(
                                label: 'Nombre completo',
                                icon: Icons.person_outline,
                                hint: 'Ingresa tu nombre',
                              ),
                              const SizedBox(height: 16),

                              // Email
                              _buildTextField(
                                label: 'Email',
                                icon: Icons.email_outlined,
                                hint: 'ejemplo@ecogrid.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),

                              // Contraseña
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
                              const SizedBox(height: 16),

                              // Confirmar Contraseña
                              _buildTextField(
                                label: 'Confirmar contraseña',
                                icon: Icons.lock_outline, // O security
                                hint: '••••••••',
                                obscureText: _obscureConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: _placeholderText,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Legal Checkbox
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _acceptedTerms,
                                      activeColor: _mintProtagonist,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: BorderSide(color: _placeholderText),
                                      onChanged: (val) {
                                        setState(() {
                                          _acceptedTerms = val ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'He leído y acepto los ',
                                        style: TextStyle(
                                          color: _forestGreenText.withValues(
                                            alpha: 0.8,
                                          ),
                                          fontSize: 12,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'Términos y Condiciones',
                                            style: const TextStyle(
                                              color: _mintProtagonist,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const TextSpan(
                                            text:
                                                ' y la Política de Privacidad.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Botón Crear Cuenta
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      _mintProtagonist,
                                      _turquoiseTechnical,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(28),
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
                                      // Acción registrar
                                      if (_acceptedTerms) {
                                        context.go('/main-menu');
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Debes aceptar los términos y condiciones',
                                            ),
                                            backgroundColor: _forestGreenText,
                                          ),
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(28),
                                    child: const Center(
                                      child: Text(
                                        'Crear cuenta',
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
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Inicia sesión
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿Ya tienes cuenta? ',
                          style: TextStyle(
                            color: _forestGreenText.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go('/login');
                          },
                          child: const Text(
                            'Inicia sesión',
                            style: TextStyle(
                              color: _mintProtagonist,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: _forestGreenText,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.transparent),
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
