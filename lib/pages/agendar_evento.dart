import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _horaController.text = "${picked.hour}:${picked.minute}";
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

      final insertResponse = await Supabase.instance.client
          .from('eventos')
          .insert(reserva)
          .select();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva guardada exitosamente.')),
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
        SnackBar(content: Text('Error al guardar la reserva: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de Evento',
                  border: OutlineInputBorder(),
                ),
                value: selectedTipoEvento,
                items: tiposEvento.map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTipoEvento = newValue;
                    _precioTotal = 0.0;
                    _cancionesController.clear();
                    _horasController.clear();
                    selectedSonido = null;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione un tipo de evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (selectedTipoEvento == 'Serenata') ...[
                TextFormField(
                  controller: _cancionesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número de Canciones (Mínimo 5)',
                    border: OutlineInputBorder(),
                  ),
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
                ),
              ] else if (selectedTipoEvento == 'Evento') ...[
                TextFormField(
                  controller: _horasController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número de Horas (Mínimo 1)',
                    border: OutlineInputBorder(),
                  ),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: '¿Con sonido?',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedSonido,
                  items: ['Con Sonido', 'Sin Sonido'].map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSonido = newValue;
                      final intValue = int.tryParse(_horasController.text);
                      if (intValue != null) {
                        _calcularPrecioEvento(intValue, selectedSonido);
                        setState(() {});
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor seleccione una opción';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(
                  labelText: 'Fecha del Evento',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una fecha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _horaController,
                decoration: InputDecoration(
                  labelText: 'Hora del Evento',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor seleccione una hora';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Número de Contacto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un número de contacto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _detallesAdicionalesController,
                decoration: const InputDecoration(
                  labelText: 'Detalles Adicionales',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Precio Total: \$${_precioTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _guardarReserva,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Confirmar Reserva',
                  style: TextStyle(fontSize: 16),
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
    _detallesAdicionalesController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _contactoController.dispose();
    _cancionesController.dispose();
    _horasController.dispose();
    super.dispose();
  }
}
