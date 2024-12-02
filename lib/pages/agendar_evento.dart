import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class AgendarEventoPage extends StatefulWidget {
  const AgendarEventoPage({super.key});

  @override
  _AgendarEventoPageState createState() => _AgendarEventoPageState();
}

class _AgendarEventoPageState extends State<AgendarEventoPage> {
  final _formKey = GlobalKey<FormState>();

  final _detallesAdicionalesController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _contactoController = TextEditingController();
  final _cancionesController = TextEditingController();
  final _horasController = TextEditingController();

  List<String> tiposEvento = ['Serenata', 'Evento'];
  String? selectedTipoEvento;
  String? selectedSonido;

  double _precioTotal = 0.0;

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

  void _calcularPrecioSerenata(int cantidadCanciones) {
    const double precioBase = 2400;
    const double precioPorCancionExtra = 480;

    if (cantidadCanciones <= 5) {
      _precioTotal = precioBase;
    } else {
      _precioTotal = precioBase + (cantidadCanciones - 5) * precioPorCancionExtra;
    }
  }

  void _calcularPrecioEvento(int cantidadHoras, String? sonido) {
    const double precioBaseConSonido = 3000;
    const double precioBaseSinSonido = 2800;
    const double precioHoraExtraConSonido = 2000;
    const double precioHoraExtraSinSonido = 1800;

    if (sonido == 'Con Sonido') {
      if (cantidadHoras == 1) {
        _precioTotal = precioBaseConSonido;
      } else {
        _precioTotal = precioBaseConSonido + (cantidadHoras - 1) * precioHoraExtraConSonido;
      }
    } else if (sonido == 'Sin Sonido') {
      if (cantidadHoras == 1) {
        _precioTotal = precioBaseSinSonido;
      } else {
        _precioTotal = precioBaseSinSonido + (cantidadHoras - 1) * precioHoraExtraSinSonido;
      }
    }
  }

  bool _horaConflictuante(TimeOfDay nuevaHora, TimeOfDay horaExistente) {
    final nueva = nuevaHora.hour * 60 + nuevaHora.minute;
    final existente = horaExistente.hour * 60 + horaExistente.minute;

    return (nueva - existente).abs() < 30;
  }

  bool _rangoHoraConflictuante(TimeOfDay nuevaHora, TimeOfDay horaExistente, int horasReservadas) {
    final nueva = nuevaHora.hour * 60 + nuevaHora.minute;
    final inicio = horaExistente.hour * 60 + horaExistente.minute;
    final fin = inicio + horasReservadas * 60;

    return nueva >= inicio && nueva < fin;
  }

  Future<void> _guardarReserva() async {
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
        final tipo = reserva['tipo_evento'];
        final horaReserva = TimeOfDay(
          hour: int.parse(reserva['hora'].split(":")[0]),
          minute: int.parse(reserva['hora'].split(":")[1]),
        );
        final horasReservadas = reserva['horas'] ?? 1;

        if (_horaConflictuante(horaSeleccionada, horaReserva) &&
            selectedTipoEvento == 'Serenata' &&
            tipo == 'Serenata') {
          throw 'Ya hay una serenata reservada en ese horario.';
        }

        if (_rangoHoraConflictuante(horaSeleccionada, horaReserva, horasReservadas) &&
            selectedTipoEvento == 'Evento' &&
            tipo == 'Evento') {
          throw 'Ya hay un evento en ese horario.';
        }
      }

      final correo = Supabase.instance.client.auth.currentUser?.email;
      if (correo == null) {
        throw 'No se encontró el correo del usuario autenticado.';
      }

      final reserva = {
        'correo': correo,
        'tipo_evento': selectedTipoEvento,
        'fecha': _fechaController.text,
        'hora': _horaController.text,
        'contacto': _contactoController.text,
        'detalles_adicionales': _detallesAdicionalesController.text,
        'monto': _precioTotal.toInt(),
        'canciones': selectedTipoEvento == 'Serenata'
            ? int.tryParse(_cancionesController.text)
            : null,
        'sonido': selectedTipoEvento == 'Evento' ? selectedSonido : null,
        'horas': selectedTipoEvento == 'Evento'
            ? int.tryParse(_horasController.text)
            : null,
      };

      // ignore: unused_local_variable
      final insertResponse = await Supabase.instance.client
          .from('eventos')
          .insert(reserva)
          .select();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva guardada exitosamente.', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF892E2E),
        ),
      );

      setState(() {
        _formKey.currentState!.reset();
        _detallesAdicionalesController.clear();
        _fechaController.clear();
        _horaController.clear();
        _contactoController.clear();
        _cancionesController.clear();
        _horasController.clear();
        selectedTipoEvento = null;
        selectedSonido = null;
        _precioTotal = 0.0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agendar Evento',
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
                          'Detalles del Evento',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF892E2E),
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildDropdownField(
                          label: 'Tipo de Evento',
                          value: selectedTipoEvento,
                          items: tiposEvento,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTipoEvento = newValue;
                              _precioTotal = 0.0;
                              _cancionesController.clear();
                              _horasController.clear();
                              selectedSonido = null;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        if (selectedTipoEvento == 'Serenata')
                          _buildTextField(
                            controller: _cancionesController,
                            label: 'Número de Canciones (Mínimo 5)',
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final intValue = int.tryParse(value);
                              if (intValue != null) {
                                _calcularPrecioSerenata(intValue);
                                setState(() {});
                              }
                            },
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
                          )
                        else if (selectedTipoEvento == 'Evento')
                          Column(
                            children: [
                              _buildTextField(
                                controller: _horasController,
                                label: 'Número de Horas (Mínimo 1)',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final intValue = int.tryParse(value);
                                  if (intValue != null && selectedSonido != null) {
                                    _calcularPrecioEvento(intValue, selectedSonido);
                                    setState(() {});
                                  }
                                },
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
                              _buildDropdownField(
                                label: '¿Con sonido?',
                                value: selectedSonido,
                                items: ['Con Sonido', 'Sin Sonido'],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedSonido = newValue;
                                    final intValue = int.tryParse(_horasController.text);
                                    if (intValue != null) {
                                      _calcularPrecioEvento(intValue, selectedSonido);
                                    }
                                  });
                                },
                              ),
                            ],
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
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _detallesAdicionalesController,
                          label: 'Detalles Adicionales',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resumen',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF892E2E),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Precio Total: \$${_precioTotal.toStringAsFixed(2)}',
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF892E2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _guardarReserva,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF892E2E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirmar Reserva',
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
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
      value: value,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor seleccione una opción';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
    int? maxLines,
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
      onChanged: onChanged,
      validator: validator,
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

