import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditarPerfilPage extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final User user;

  const EditarPerfilPage({
    super.key,
    required this.profileData,
    required this.user,
  });

  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;
  late TextEditingController _fechaNacimientoController;
  String? _profileImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.profileData['full_name'] ?? '',
    );
    _telefonoController = TextEditingController(
      text: widget.profileData['phone_number'] ?? '',
    );
    _fechaNacimientoController = TextEditingController(
      text: widget.profileData['birth_date'] ?? '',
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  Future<String?> _subirImagen() async {
    if (_profileImagePath == null) return null;

    try {
      final fileName = '${widget.user.id}/profile_picture.png';

      await Supabase.instance.client.storage.from('avatars').upload(
            fileName,
            File(_profileImagePath!),
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl =
          Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);

      return imageUrl;
    } catch (error) {
      print('Error al subir imagen: $error');
      return null;
    }
  }

  Future<void> _guardarCambios() async {
    if (_telefonoController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de teléfono incompleto')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;
      if (_profileImagePath != null) {
        imageUrl = await _subirImagen();
      }

      Map<String, dynamic> updateData = {
        'full_name': _nombreController.text,
        'phone_number': _telefonoController.text,
        'birth_date': _fechaNacimientoController.text,
      };

      if (imageUrl != null) {
        updateData['avatar_url'] = imageUrl;
      }

      await Supabase.instance.client
          .from('users')
          .update(updateData)
          .eq('user_id', widget.user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado con éxito')),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar perfil: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
        backgroundColor: const Color(0xFF892E2E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : (widget.profileData['avatar_url'] != null
                            ? NetworkImage(widget.profileData['avatar_url'])
                            : const AssetImage('assets/images/person.png')
                                as ImageProvider),
                    child: _profileImagePath == null &&
                            widget.profileData['avatar_url'] == null
                        ? const Icon(Icons.person, color: Colors.white, size: 40)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF892E2E),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10, // Limita a 10 caracteres
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _fechaNacimientoController,
              decoration: const InputDecoration(
                labelText: 'Fecha de Nacimiento',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _fechaNacimientoController.text =
                        '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarCambios,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF892E2E),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }
}
