import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Para manejar fechas

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

  // Método para seleccionar la fecha de nacimiento
  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  // Método para registrar al usuario
  Future<void> _signUp() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();

    // Validaciones básicas
    if (fullName.isEmpty || email.isEmpty || password.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una fecha de nacimiento válida.')),
      );
      return;
    }

    try {
      // Paso 1: Crear el usuario en Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar usuario: ${response.error!.message}')),
        );
        return;
      }

      // Obtener el user_id generado por Supabase Auth
      final userId = response.user?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener el ID del usuario. Inténtalo de nuevo.')),
        );
        return;
      }

      // Agregar un pequeño retraso para evitar problemas de sincronización
      await Future.delayed(const Duration(milliseconds: 500));

      // Paso 2: Insertar los datos adicionales en la tabla 'users'
      final insertResponse = await Supabase.instance.client.from('users').insert({
        'user_id': userId, // Relacionar con auth.users
        'full_name': fullName,
        'email': email,
        'birth_date': _birthDate!.toIso8601String(),
        'phone_number': phoneNumber,
      }).select().single();

      if (insertResponse.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al insertar datos: ${insertResponse.error!.message}')),
        );
        return;
      }

      // Registro exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );

      Navigator.pop(context); // Regresar a la pantalla de login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Nombre Completo'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _birthDate == null
                      ? 'Selecciona tu fecha de nacimiento'
                      : 'Fecha: ${DateFormat('yyyy-MM-dd').format(_birthDate!)}',
                ),
                TextButton(
                  onPressed: () => _selectBirthDate(context),
                  child: const Text('Seleccionar Fecha'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Número de Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}

extension on AuthResponse {
  get error => null;
}

extension on PostgrestMap {
  get error => null;
}
