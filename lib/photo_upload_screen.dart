import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled1/api_service.dart'; // Adjust import path if needed

class PhotoUploadScreen extends StatefulWidget {
  final String ticketId;
  const PhotoUploadScreen({super.key, required this.ticketId});

  @override
  _PhotoUploadScreenState createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  final List<String> _photoTypes = [
    'Antenna Mount',
    'Cable route',
    'IDU installation',
    'Speed test result',
  ];
  final Map<String, XFile> _takenPhotos = {};

  // --- REFINED LOGIC: ROBUST PHOTO TAKING WITH ERROR HANDLING ---
  Future<void> _takePhoto(String type) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Compress image to save bandwidth
        maxWidth: 1280,   // Resize to prevent very large files
      );

      // Check if a photo was actually taken and if the widget is still on screen
      if (photo != null && mounted) {
        setState(() {
          _takenPhotos[type] = photo;
        });
      }
    } catch (e) {
      // If an error occurs (e.g., permissions denied), show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access camera. Please check app permissions. Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadPhotos() async {
    if (_takenPhotos.length < _photoTypes.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide all required photos.')),
      );
      return;
    }
    setState(() => _isUploading = true);

    try {
      final photosToUpload = _takenPhotos.entries.map((entry) {
        return {'type': entry.key, 'file': entry.value};
      }).toList();

      await ApiService.uploadInstallationPhotos(widget.ticketId, photosToUpload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photos uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to signal success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);
    final canUpload = _takenPhotos.length == _photoTypes.length && !_isUploading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Installation Photos', style: TextStyle(color: Colors.white, fontFamily: 'Nunito')),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _photoTypes.length,
            itemBuilder: (context, index) {
              final type = _photoTypes[index];
              final photoFile = _takenPhotos[type];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  leading: CircleAvatar(
                    radius: 30,
                    // Use dart:io's FileImage to display the preview
                    backgroundImage: photoFile != null ? FileImage(File(photoFile.path)) : null,
                    child: photoFile == null ? const Icon(Icons.photo_library_outlined, size: 30) : null,
                  ),
                  title: Text(type, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.camera_alt, color: primaryColor, size: 30),
                    onPressed: () => _takePhoto(type),
                  ),
                ),
              );
            },
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Uploading Photos...', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.cloud_upload),
          label: const Text('UPLOAD ALL PHOTOS'),
          style: ElevatedButton.styleFrom(
            backgroundColor: canUpload ? primaryColor : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: canUpload ? _uploadPhotos : null,
        ),
      ),
    );
  }
}