import 'package:flutter/material.dart';
import 'package:flutter_application_trio/pages/auth/recuperar_contrase%C3%B1a.dart';
import '../principal_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_page.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.session?.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PrincipalPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al iniciar sesión',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF892E2E),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF892E2E),
        ),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
      );

      // Agregamos una verificación del usuario después de la redirección
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PrincipalPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo completar el inicio de sesión con Google',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color(0xFF892E2E),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al iniciar sesión con Google: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF892E2E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Iniciar Sesión',
          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF892E2E),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'lib/assets/images/logo_trio.png',
                    width: 190,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Bienvenido de vuelta',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF892E2E),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: Color(0xFF892E2E)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF892E2E), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    prefixIcon: Icon(Icons.email, color: Color(0xFF892E2E)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: Color(0xFF892E2E)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF892E2E), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF892E2E)),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF892E2E),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Iniciar Sesión',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loginWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    'Iniciar sesión con Google',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF892E2E),
                  ),
                  child: Text(
                    '¿No tienes cuenta? Regístrate aquí',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecuperarContrasenaPage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF892E2E),
                  ),
                  child: Text(
                    '¿Olvidaste tu contraseña? Recupérala aquí',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
