import 'package:flutter/material.dart';

class AgendarEventoPage extends StatefulWidget {
  const AgendarEventoPage({super.key});

  @override
  _AgendarEventoPageState createState() => _AgendarEventoPageState();
}

class _AgendarEventoPageState extends State<AgendarEventoPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nombreEventoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _anticipoController = TextEditingController();

  // Dropdown values
  List<String> tiposEvento = ['XV Años', 'Boda', 'Otro'];
  String? selectedTipoEvento;

  // Date picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Time picker function
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _horaController.text = picked.format(context);
      });
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
              // Nombre del Evento
              TextFormField(
                controller: _nombreEventoController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo de Evento Dropdown
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

              // Fecha
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

              // Hora
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

              // Ubicación
              TextFormField(
                controller: _ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación del Evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la ubicación del evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Anticipo
              TextFormField(
                controller: _anticipoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto de Anticipo',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el monto del anticipo';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón de Confirmar
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aquí puedes agregar la lógica para guardar el evento
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Evento "${_nombreEventoController.text}" agendado exitosamente',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Confirmar Evento',
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
    // Limpiar los controladores cuando el widget se dispose
    _nombreEventoController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _ubicacionController.dispose();
    _anticipoController.dispose();
    super.dispose();
  }
}