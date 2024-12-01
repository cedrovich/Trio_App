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
    required this.user
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
    // Inicializar controladores con los datos actuales
    _nombreController = TextEditingController(
      text: widget.profileData['full_name'] ?? ''
    );
    _telefonoController = TextEditingController(
      text: widget.profileData['phone_number'] ?? ''
    );
    _fechaNacimientoController = TextEditingController(
      text: widget.profileData['birth_date'] ?? ''
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
      // Nombre de archivo único
      final fileName = '${widget.user.id}/profile_picture.png';
      
      // Subir imagen a Supabase Storage
      await Supabase.instance.client.storage.from('avatars').upload(
        fileName, 
        File(_profileImagePath!),
        fileOptions: FileOptions(upsert: true)
      );

      // Obtener URL pública de la imagen
      final imageUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);

      return imageUrl;
    } catch (error) {
      print('Error al subir imagen: $error');
      return null;
    }
  }

  Future<void> _guardarCambios() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Subir imagen si se seleccionó una nueva
      String? imageUrl;
      if (_profileImagePath != null) {
        imageUrl = await _subirImagen();
      }

      // Preparar datos para actualizar
      Map<String, dynamic> updateData = {
        'full_name': _nombreController.text,
        'phone_number': _telefonoController.text,
        'birth_date': _fechaNacimientoController.text,
      };

      // Añadir URL de imagen si se subió una nueva
      if (imageUrl != null) {
        updateData['avatar_url'] = imageUrl;
      }

      // Actualizar en la base de datos
      await Supabase.instance.client
        .from('users')
        .update(updateData)
        .eq('user_id', widget.user.id);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil actualizado con éxito')),
      );

      // Regresar a la pantalla anterior
      Navigator.of(context).pop(true);
    } catch (error) {
      // Mostrar error
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
        title: Text('Editar Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil con opción de edición
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImagePath != null
                      ? FileImage(File(_profileImagePath!))
                      : (widget.user.userMetadata?['avatar_url'] != null
                        ? NetworkImage(widget.user.userMetadata!['avatar_url'])
                        : AssetImage('assets/images/person.png') as ImageProvider),
                    child: _profileImagePath == null && widget.user.userMetadata?['avatar_url'] == null
                      ? Icon(Icons.person, color: Colors.white, size: 40)
                      : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Campo de nombre
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo',
                border: OutlineInputBorder(),
              ),
            ),
            
            SizedBox(height: 15),
            
            // Campo de teléfono
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            
            SizedBox(height: 15),
            
            // Campo de fecha de nacimiento
            TextField(
              controller: _fechaNacimientoController,
              decoration: InputDecoration(
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
            
            SizedBox(height: 20),
            
            // Botón de guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _guardarCambios,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: _isLoading 
                ? CircularProgressIndicator() 
                : Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar controladores
    _nombreController.dispose();
    _telefonoController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }
}