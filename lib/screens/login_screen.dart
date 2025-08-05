import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late VideoPlayerController _videoController1;
  late VideoPlayerController _videoController2;
  bool _isLoading = false;
  bool _isFirstVideo = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();

    // Inicializar controlador de animación para crossfade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Inicializar dos controladores de video
    _videoController1 = VideoPlayerController.asset('assets/background.mp4');
    _videoController2 = VideoPlayerController.asset('assets/background.mp4');

    _initializeVideos();
  }

  Future<void> _initializeVideos() async {
    try {
      await _videoController1.initialize();
      await _videoController2.initialize();

      if (mounted) {
        setState(() {});
        
        // Configurar videos sin loop
        _videoController1.setLooping(false);
        _videoController2.setLooping(false);
        
        // Iniciar el primer video
        _videoController1.play();
        
        // Configurar listeners
        _videoController1.addListener(_onVideoProgress);
        _videoController2.addListener(_onVideoProgress);
      }
    } catch (e) {
      print('Error initializing videos: $e');
    }
  }

  void _onVideoProgress() {
    if (!mounted || _isTransitioning) return;

    final currentController = _isFirstVideo ? _videoController1 : _videoController2;
    final position = currentController.value.position;
    final duration = currentController.value.duration;

    if (duration != Duration.zero && position != Duration.zero) {
      // Detectar cuando el video está a 1 segundo del final
      if (position >= duration - const Duration(seconds: 1)) {
        _startCrossfade();
      }
    }
  }

  void _startCrossfade() {
    if (!mounted || _isTransitioning) return;

    setState(() {
      _isTransitioning = true;
    });

    final nextController = _isFirstVideo ? _videoController2 : _videoController1;
    
    // Preparar el siguiente video
    nextController.seekTo(Duration.zero);
    nextController.play();
    
    // Iniciar animación de crossfade
    _fadeController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isFirstVideo = !_isFirstVideo;
          _isTransitioning = false;
        });
        _fadeController.reset();
      }
    });
  }

  void _showCreativeError(String message, {String? icon, Color? color}) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.95 * 255).round()),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.2 * 255).round()),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono animado
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (color ?? AppColors.softPink).withAlpha((0.2 * 255).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon == 'warning' ? Icons.warning_amber_rounded : 
                    icon == 'error' ? Icons.error_outline_rounded : 
                    Icons.info_outline_rounded,
                    size: 40,
                    color: color ?? AppColors.softPink,
                  ),
                )
                    .animate()
                    .scale(duration: 300.ms, begin: const Offset(0.5, 0.5), end: const Offset(1, 1))
                    .then()
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2.seconds, color: Colors.white.withAlpha((0.3 * 255).round())),
                
                const SizedBox(height: 16),
                
                // Mensaje
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),
                
                const SizedBox(height: 20),
                
                // Botón de cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color ?? AppColors.softPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Entendido',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        )
            .animate()
            .scale(duration: 300.ms, begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
            .fadeIn(duration: 300.ms);
      },
    );
  }

  Future<void> signIn() async {
    if (emailController.text.trim().isEmpty || passwordController.text.isEmpty) {
      if (!mounted) return;
      _showCreativeError(
        '¡Ups! Parece que olvidaste completar algunos campos.\n\n📧 Email y 🔒 Contraseña son necesarios para continuar.',
        icon: 'warning',
        color: Colors.orange,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (mounted) {
        setState(() {}); // Actualiza para AuthGate
      }
    } catch (e) {
      if (!mounted) return;
      _showCreativeError(
        '¡Oops! Esas credenciales no coinciden.\n\n🔍 Verifica tu email y contraseña, o si es la primera vez, ¡crea tu cuenta!',
        icon: 'error',
        color: Colors.red.shade300,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _videoController1.dispose();
    _videoController2.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video de fondo con crossfade suave
          if (_videoController1.value.isInitialized && _videoController2.value.isInitialized)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      // Video principal
                      Positioned.fill(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController1.value.size.width,
                            height: _videoController1.value.size.height,
                            child: VideoPlayer(_isFirstVideo ? _videoController1 : _videoController2),
                          ),
                        ),
                      ),
                      // Video de transición (solo visible durante crossfade)
                      if (_fadeAnimation.value > 0)
                        Positioned.fill(
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController2.value.size.width,
                                height: _videoController2.value.size.height,
                                child: VideoPlayer(_isFirstVideo ? _videoController2 : _videoController1),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

          // Overlay gradiente para mejorar legibilidad
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha((0.3 * 255).round()),
                    Colors.black.withAlpha((0.1 * 255).round()),
                    Colors.black.withAlpha((0.3 * 255).round()),
                  ],
                ),
              ),
            ),
          ),

          // Contenedor del formulario de login
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.95 * 255).round()),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.2 * 255).round()),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo animado
                    SizedBox(
                      height: 120, // Aumentado de 80 a 120
                      width: double.infinity,
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            'Closet Virtual 👗',
                            style: GoogleFonts.raleway(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.liberty,
                            ),
                          );
                        },
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.3, end: 0)
                        .then()
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .scale(
                          duration: 3.seconds,
                          begin: const Offset(1, 1),
                          end: const Offset(1.02, 1.02),
                        )
                        .then()
                        .scale(
                          duration: 3.seconds,
                          begin: const Offset(1.02, 1.02),
                          end: const Offset(1, 1),
                        ),

                    const SizedBox(height: 32),

                    // Input de email decorado
                    _buildDecoratedTextField(
                      controller: emailController,
                      labelText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideX(begin: -0.3, end: 0),

                    const SizedBox(height: 20),

                    // Input de contraseña decorado
                    _buildDecoratedTextField(
                      controller: passwordController,
                      labelText: 'Contraseña',
                      icon: Icons.lock_outlined,
                      isPassword: true,
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideX(begin: -0.3, end: 0),

                    const SizedBox(height: 32),

                    // Botón de login animado
                    _buildAnimatedLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecoratedTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withAlpha((0.9 * 255).round()),
            Colors.white.withAlpha((0.7 * 255).round()),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softPink.withAlpha((0.3 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          color: AppColors.darkText,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.montserrat(
            color: AppColors.liberty.withAlpha((0.7 * 255).round()),
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.liberty,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            AppColors.softPink,
            AppColors.softPink.withAlpha((0.8 * 255).round()),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.softPink.withAlpha((0.4 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : signIn,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.liberty,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login,
                          color: AppColors.liberty,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Iniciar Sesión',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.liberty,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0)
        .then()
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: 3.seconds,
          color: Colors.white.withAlpha((0.3 * 255).round()),
        );
  }
}
