import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecuperarContrasenaPage extends StatefulWidget {
  const RecuperarContrasenaPage({Key? key}) : super(key: key);

  @override
  _RecuperarContrasenaPageState createState() => _RecuperarContrasenaPageState();
}

class _RecuperarContrasenaPageState extends State<RecuperarContrasenaPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _recuperarContrasena() {
    if (_formKey.currentState!.validate()) {
      // Aquí implementarías la lógica de envío de correo de recuperación
      // Podrías usar un servicio como Firebase Authentication o tu propio backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Se ha enviado un correo de recuperación a ${_emailController.text}',
            style: GoogleFonts.roboto(),
          ),
          backgroundColor: const Color(0xFF892E2E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recuperar Contraseña',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Comenté la imagen ya que necesitarías agregarla a tus assets
              // Image.asset(
              //   'assets/password_reset.png', 
              //   height: 200,
              // ),
              const SizedBox(height: 20),
              Text(
                'Recupera tu contraseña',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF892E2E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ingresa tu correo electrónico y te enviaremos instrucciones para recuperar tu contraseña',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF892E2E)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF892E2E), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo electrónico';
                  }
                  // Validación básica de correo electrónico
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Ingresa un correo electrónico válido';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _recuperarContrasena,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF892E2E),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Enviar Correo de Recuperación',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}