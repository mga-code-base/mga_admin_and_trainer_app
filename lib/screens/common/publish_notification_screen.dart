import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class PublishNotificationScreen extends StatefulWidget {
  const PublishNotificationScreen({super.key});

  @override
  State<PublishNotificationScreen> createState() => _PublishNotificationScreenState();
}

class _PublishNotificationScreenState extends State<PublishNotificationScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController();

  String? _base64ImageString;
  File? _selectedImageFile;
  bool _isLoading = false;

  static const Color _themeAccent = Color(0xFF4CD964);

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

      if (image != null) {
        final File file = File(image.path);
        final List<int> imageBytes = await file.readAsBytes();

        setState(() {
          _selectedImageFile = file;
          _base64ImageString = base64Encode(imageBytes);
        });
      }
    } catch (e) {
      print('Error selecting image asset file: $e');
    }
  }

  void _submitBroadcastForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final String activeAdmin = await authCacheService.getCachedUsername();

    final Map<String, dynamic> broadcastBodyPayload = {
      "senderId": activeAdmin.isEmpty ? "Flutter-Client-App" : activeAdmin,
      "content": _messageCtrl.text.trim(),
      "image": _base64ImageString ?? ""
    };

    bool success = await _apiService.broadcastNotificationPayload(broadcastBodyPayload);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification broadcast transmitted successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit broadcast payload to producer.'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Theme(
        data: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F14),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF16161F),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _themeAccent),
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF16161F),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _themeAccent, width: 1.5),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Broadcast System Notice'),
              iconTheme: const IconThemeData(color: _themeAccent),
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _themeAccent))
                : SafeArea(
                child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: deviceHeight * 0.02),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const Text(
                        'Issue Broad Announcement',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: deviceHeight * 0.025),
                      TextFormField(
                        controller: _messageCtrl,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          labelText: 'Announcement Message Body Text Content',
                          hintText: 'Type your message text details here...',
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please provide announcement narrative content' : null,
                      ),
                      SizedBox(height: deviceHeight * 0.025),
                      const Text(
                        'Optional Notice Banner Artwork Asset',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white70),
                      ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickImageFromGallery,

                                icon: const Icon(Icons.image_search, color: _themeAccent),
                                label: const Text('Select Image File'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E1E2A),
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white10),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _selectedImageFile != null
                                      ? 'Selected File: ${_selectedImageFile!.path.split(Platform.pathSeparator).last}'
                                      : 'No image uploaded (Will submit as empty string)',

                                  style: TextStyle(fontSize: 12, color: _selectedImageFile != null ? _themeAccent : Colors.white38),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (_selectedImageFile != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),

                                border: Border.all(color: _themeAccent.withOpacity(0.3), width: 1.2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_selectedImageFile!, height: deviceHeight * 0.15, width: double.infinity, fit: BoxFit.cover),
                              ),
                            ),
                          ],
                          SizedBox(height: deviceHeight * 0.04),
                          SizedBox(
                            width: double.infinity,
                            height: deviceHeight * 0.055,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(

                                backgroundColor: _themeAccent,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _submitBroadcastForm,
                              icon: const Icon(Icons.send_and_archive, color: Colors.black),
                              label: const Text('Transmit Broadcast Payload', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
            ),
        ),
    );
  }
}
