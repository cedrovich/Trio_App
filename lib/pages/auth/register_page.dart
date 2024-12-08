
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  DateTime? _birthDate;

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF892E2E)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _signUp() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();

    if (fullName.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa todos los campos.', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF892E2E),
        ),
      );
      return;
    }

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor selecciona una fecha de nacimiento válida.', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF892E2E),
        ),
      );
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar usuario: ${response.error!.message}', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF892E2E),
          ),
        );
        return;
      }

      final userId = response.user?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo obtener el ID del usuario. Inténtalo de nuevo.', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF892E2E),
          ),
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final insertResponse = await Supabase.instance.client.from('users').insert({
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        'birth_date': _birthDate!.toIso8601String(),
        'phone_number': phoneNumber,
        'role': 'cliente', // Se agrega el rol directamente en la base de datos
      }).select().single();

      if (insertResponse.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al insertar datos: ${insertResponse.error!.message}', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF892E2E),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registro exitoso', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF892E2E),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: TextStyle(color: Colors.white)),
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
          'Registro',
          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF892E2E),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Color(0xFF892E2E),
                ),
                SizedBox(height: 20),
                Text(
                  'Crea tu cuenta',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF892E2E),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Nombre Completo',
                  icon: Icons.person,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 20),
                _buildDatePicker(),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _phoneNumberController,
                  label: 'Número de Teléfono',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF892E2E),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Registrarse',
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
      ),
    );
  }

  Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  TextInputType? keyboardType,
  bool obscureText = false,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFF892E2E)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF892E2E), width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      prefixIcon: Icon(icon, color: Color(0xFF892E2E)),
    ),
    keyboardType: keyboardType,
    obscureText: obscureText,
    inputFormatters: label == 'Número de Teléfono'
        ? [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly,
          ]
        : null,
  );
}

  Widget _buildDatePicker() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth, // Limita el ancho máximo al tamaño de la pantalla
          ),
          child: InkWell(
            onTap: () => _selectBirthDate(context),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Fecha de Nacimiento',
                labelStyle: TextStyle(color: Color(0xFF892E2E)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF892E2E), width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF892E2E)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _birthDate == null
                          ? 'Selecciona tu fecha de nacimiento'
                          : DateFormat('yyyy-MM-dd').format(_birthDate!),
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis, // Ajusta el texto si es muy largo
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Color(0xFF892E2E)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

extension on PostgrestMap {
  get error => null;
}

extension on AuthResponse {
  get error => null;
}
