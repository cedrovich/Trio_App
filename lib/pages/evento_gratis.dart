import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class EventoGratisPage extends StatefulWidget {
  const EventoGratisPage({super.key});

  @override
  _EventoGratisPageState createState() => _EventoGratisPageState();
}

class _EventoGratisPageState extends State<EventoGratisPage> {
  final _formKey = GlobalKey<FormState>();

  final _detallesAdicionalesController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _contactoController = TextEditingController();
  final _cancionesController = TextEditingController();
  final _horasController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF892E2E),
            colorScheme: ColorScheme.light(primary: Color(0xFF892E2E)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF892E2E),
            colorScheme: ColorScheme.light(primary: Color(0xFF892E2E)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _horaController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _guardarReservaGratis() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final fechaSeleccionada = DateTime.parse(_fechaController.text);
      final horaSeleccionada = TimeOfDay(
        hour: int.parse(_horaController.text.split(":")[0]),
        minute: int.parse(_horaController.text.split(":")[1]),
      );
      final fechaHoraSeleccionada = DateTime(
        fechaSeleccionada.year,
        fechaSeleccionada.month,
        fechaSeleccionada.day,
        horaSeleccionada.hour,
        horaSeleccionada.minute,
      );

      if (fechaHoraSeleccionada.isBefore(DateTime.now())) {
        throw 'No puedes reservar en una fecha pasada.';
      }

      final response = await Supabase.instance.client
          .from('eventos')
          .select()
          .eq('fecha', _fechaController.text);

      final reservasExistentes = response as List<dynamic>;
      for (final reserva in reservasExistentes) {
        final horaReserva = TimeOfDay(
          hour: int.parse(reserva['hora'].split(":")[0]),
          minute: int.parse(reserva['hora'].split(":")[1]),
        );
        final horasReservadas = reserva['horas'] ?? 1;

        // Verificar conflictos de horario para eventos gratuitos
        if (_rangoHoraConflictuante(horaSeleccionada, horaReserva, horasReservadas)) {
          throw 'Ya hay un evento reservado en ese horario.';
        }
      }

      final correo = Supabase.instance.client.auth.currentUser?.email;
      if (correo == null) {
        throw 'No se encontró el correo del usuario autenticado.';
      }

      final reserva = {
        'correo': correo,
        'tipo_evento': 'Evento Gratis',
        'fecha': _fechaController.text,
        'hora': _horaController.text,
        'contacto': _contactoController.text,
        'detalles_adicionales': _detallesAdicionalesController.text,
        'monto': 0, // Evento gratuito
        'canciones': int.tryParse(_cancionesController.text),
        'horas': int.tryParse(_horasController.text) ?? 1,
      };

      await Supabase.instance.client
          .from('eventos')
          .insert(reserva)
          .select();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva de evento gratis guardada exitosamente.', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF892E2E),
        ),
      );

      // Resetear el formulario
      setState(() {
        _formKey.currentState!.reset();
        _detallesAdicionalesController.clear();
        _fechaController.clear();
        _horaController.clear();
        _contactoController.clear();
        _cancionesController.clear();
        _horasController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar la reserva: $e', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _rangoHoraConflictuante(TimeOfDay nuevaHora, TimeOfDay horaExistente, int horasReservadas) {
    final nueva = nuevaHora.hour * 60 + nuevaHora.minute;
    final inicio = horaExistente.hour * 60 + horaExistente.minute;
    final fin = inicio + horasReservadas * 60;

    return nueva >= inicio && nueva < fin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Evento Gratis',
          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF892E2E),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF892E2E), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles del Evento Gratis',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF892E2E),
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _cancionesController,
                          label: 'Número de Canciones (Mínimo 5)',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la cantidad de canciones';
                            }
                            final intValue = int.tryParse(value);
                            if (intValue == null || intValue < 5) {
                              return 'Debe ingresar al menos 5 canciones';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _horasController,
                          label: 'Número de Horas (Mínimo 1)',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese la cantidad de horas';
                            }
                            final intValue = int.tryParse(value);
                            if (intValue == null || intValue < 1) {
                              return 'Debe ingresar al menos 1 hora';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        _buildDateField(
                          controller: _fechaController,
                          label: 'Fecha del Evento',
                          onTap: () => _selectDate(context),
                        ),
                        SizedBox(height: 16),
                        _buildTimeField(
                          controller: _horaController,
                          label: 'Hora del Evento',
                          onTap: () => _selectTime(context),
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _contactoController,
                          label: 'Número de Contacto',
                          keyboardType: TextInputType.phone,
                          isPhoneNumber: true, // Activa las restricciones para 10 dígitos
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _detallesAdicionalesController,
                          label: 'Detalles Adicionales y Ubicacion del Evento',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _guardarReservaGratis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF892E2E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirmar Reserva Gratis',
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
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  int? maxLines,
  bool? isPhoneNumber, // Nuevo parámetro opcional
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFF892E2E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFF892E2E), width: 2),
      ),
    ),
    validator: validator,
    inputFormatters: isPhoneNumber == true
        ? [
            LengthLimitingTextInputFormatter(10), // Máximo 10 caracteres
            FilteringTextInputFormatter.digitsOnly, // Solo números
          ]
        : null,
  );
}


  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF892E2E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF892E2E), width: 2),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFF892E2E)),
      ),
      readOnly: true,
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor seleccione una fecha';
        }
        return null;
      },
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF892E2E)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFF892E2E), width: 2),
        ),
        suffixIcon: Icon(Icons.access_time, color: Color(0xFF892E2E)),
      ),
      readOnly: true,
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor seleccione una hora';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _detallesAdicionalesController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _contactoController.dispose();
    _cancionesController.dispose();
    _horasController.dispose();
    super.dispose();
  }
}