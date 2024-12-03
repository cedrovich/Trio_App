import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditEventPage extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EditEventPage({Key? key, required this.eventData}) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  bool _isLoading = false;

  final Color _accentColor = const Color(0xFF892E2E);

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.eventData['fecha']);
    _timeController = TextEditingController(text: widget.eventData['hora']);
  }

  Future<void> _updateEvent() async {
    setState(() => _isLoading = true);

    try {
      final newDate = _dateController.text;
      final newTime = _timeController.text;

      // Validación de conflicto de horarios
      final response = await Supabase.instance.client
          .from('eventos')
          .select()
          .neq('id', widget.eventData['id'])
          .eq('fecha', newDate);

      if (response == null || response.error != null) {
        throw response?.error?.message ?? 'Error al obtener las reservas existentes.';
      }

      final existingReservations = List<Map<String, dynamic>>.from(response as List);

      if (existingReservations.any((reservation) => reservation['hora'] == newTime)) {
        throw 'Ya existe una reserva en la misma fecha y hora.';
      }

      // Actualización del evento
      final updateResponse = await Supabase.instance.client
          .from('eventos')
          .update({'fecha': newDate, 'hora': newTime})
          .eq('id', widget.eventData['id']);

      if (updateResponse == null || updateResponse.error != null) {
        throw updateResponse?.error?.message ?? 'Error al actualizar el evento.';
      }

      _showSnackBar('Reserva actualizada con éxito.', _accentColor);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _accentColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  Future<void> _selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _accentColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        _timeController.text = selectedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Evento',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _accentColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles del Evento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF892E2E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _dateController,
                      label: 'Fecha del Evento',
                      icon: Icons.calendar_today,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _timeController,
                      label: 'Hora del Evento',
                      icon: Icons.access_time,
                      onTap: _selectTime,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Actualizar Evento',
                      style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w500),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accentColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: _accentColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                controller.text.isEmpty ? label : controller.text,
                style: TextStyle(
                  fontSize: 16,
                  color: controller.text.isEmpty ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}

extension on PostgrestList {
  get error => null;
}
