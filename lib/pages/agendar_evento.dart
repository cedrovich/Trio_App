import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Map<String, dynamic>? preciosSerenata;
  Map<String, dynamic>? preciosEvento;
  bool isLoadingPrecios = true;

  @override
  void initState() {
    super.initState();
    _fetchPrecios();
  }

Future<void> _fetchPrecios() async {
  try {
    final response = await Supabase.instance.client
        .from('precios')
        .select(); // Obtiene todas las filas sin restricciones

    if (response == null || (response as List).isEmpty) {
      throw 'No se encontraron precios en la base de datos.';
    }

    final precios = List<Map<String, dynamic>>.from(response);

    setState(() {
      preciosSerenata = precios.firstWhere(
        (p) => p['tipo_evento'] == 'serenata',
        orElse: () => <String, dynamic>{}, // Devuelve un mapa vacío en lugar de null
      );

      preciosEvento = {
        'Con Sonido': precios.firstWhere(
          (p) => p['tipo_evento'] == 'evento' && p['sonido'] == 'Con Sonido',
          orElse: () => <String, dynamic>{}, // Devuelve un mapa vacío
        ),
        'Sin Sonido': precios.firstWhere(
          (p) => p['tipo_evento'] == 'evento' && p['sonido'] == 'Sin Sonido',
          orElse: () => <String, dynamic>{}, // Devuelve un mapa vacío
        ),
      };

      isLoadingPrecios = false;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar los precios: $e')),
    );
    setState(() {
      isLoadingPrecios = false;
    });
  }
}



  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF892E2E),
            colorScheme: const ColorScheme.light(primary: Color(0xFF892E2E)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
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
            primaryColor: const Color(0xFF892E2E),
            colorScheme: const ColorScheme.light(primary: Color(0xFF892E2E)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
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
  if (preciosSerenata == null || cantidadCanciones < 5) {
    setState(() {
      _precioTotal = 0.0;
    });
    return;
  }

  final double precioBase = (preciosSerenata!['precio_base'] ?? 0.0).toDouble();
  final double precioPorCancionExtra =
      (preciosSerenata!['precio_extra'] ?? 0.0).toDouble();

  setState(() {
    if (cantidadCanciones <= 5) {
      _precioTotal = precioBase;
    } else {
      _precioTotal = precioBase + (cantidadCanciones - 5) * precioPorCancionExtra;
    }
  });
}


  void _calcularPrecioEvento(int cantidadHoras, String? sonido) {
  if (preciosEvento == null || cantidadHoras < 1 || sonido == null) {
    setState(() {
      _precioTotal = 0.0;
    });
    return;
  }

  final eventoPrecios = preciosEvento![sonido];
  if (eventoPrecios == null) {
    setState(() {
      _precioTotal = 0.0;
    });
    return;
  }

  final double precioBase = (eventoPrecios['precio_base'] ?? 0.0).toDouble();
  final double precioHoraExtra = (eventoPrecios['precio_extra'] ?? 0.0).toDouble();

  setState(() {
    if (cantidadHoras == 1) {
      _precioTotal = precioBase;
    } else {
      _precioTotal = precioBase + (cantidadHoras - 1) * precioHoraExtra;
    }
  });
}




  Future<void> _guardarReserva() async {
    if (!_formKey.currentState!.validate() || isLoadingPrecios) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Espera a que se carguen los precios o completa el formulario.')),
      );
      return;
    }

    // Lógica para guardar la reserva permanece igual
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingPrecios) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agendar Evento',
          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF892E2E),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Fondo sólido blanco
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
                                  _precioTotal = 0.0; // Reinicia el precio al cambiar el tipo de evento.
                                  _cancionesController.clear();
                                  _horasController.clear();
                                  selectedSonido = null;
                                });
                              },
                            ),
                            if (selectedTipoEvento == 'Serenata') ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _cancionesController,
                                label: 'Número de Canciones (Mínimo 5)',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final intValue = int.tryParse(value);
                                  if (intValue != null) {
                                    _calcularPrecioSerenata(intValue);
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
                              ),
                            ] else if (selectedTipoEvento == 'Evento') ...[
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _horasController,
                                label: 'Número de Horas (Mínimo 1)',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final intValue = int.tryParse(value);
                                  if (intValue != null && selectedSonido != null) {
                                    _calcularPrecioEvento(intValue, selectedSonido);
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
                              const SizedBox(height: 16),
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
                          'Precio Total: \$${_precioTotal.isFinite && _precioTotal >= 0 ? _precioTotal.toStringAsFixed(2) : '0.00'}',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF892E2E),
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
    onChanged: onChanged,
    validator: validator,
    inputFormatters: isPhoneNumber == true
        ? [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.digitsOnly,
          ]
        : null, // Aplica restricciones solo si es un número de teléfono
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

extension on PostgrestFilterBuilder<PostgrestList> {
  throwOnError() {}
}
