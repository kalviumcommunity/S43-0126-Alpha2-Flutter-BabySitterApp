import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/verification_service.dart';

class VerificationUploadScreen extends StatefulWidget {
  const VerificationUploadScreen({super.key});

  @override
  State<VerificationUploadScreen> createState() => _VerificationUploadScreenState();
}

class _VerificationUploadScreenState extends State<VerificationUploadScreen> {
  final VerificationService _verificationService = VerificationService();
  final ImagePicker _imagePicker = ImagePicker();

  final Map<String, dynamic> _selectedFiles = {
    'id': null,
    'background_check': null,
    'certificate': null,
  };

  Map<String, String> _uploadedUrls = {};
  bool _uploading = false;
  String? _uploadError;

  Future<void> _pickFile(String documentType) async {
    try {
      if (kIsWeb) {
        // Web: use file_picker
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );

        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _selectedFiles[documentType] = result.files.single;
            _uploadError = null;
          });
        }
      } else {
        // Mobile: try image picker first, then file picker
        try {
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
          );

          if (image != null) {
            setState(() {
              _selectedFiles[documentType] = File(image.path);
              _uploadError = null;
            });
            return;
          }
        } catch (_) {
          // Fallback to file picker
        }

        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any,
        );

        if (result != null && result.files.single.path != null) {
          setState(() {
            _selectedFiles[documentType] = File(result.files.single.path!);
            _uploadError = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  Future<void> _uploadAllDocuments() async {
    if (_selectedFiles.values.every((file) => file == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one document to upload')),
      );
      return;
    }

    setState(() {
      _uploading = true;
      _uploadError = null;
    });

    try {
      final Map<String, String> documentUrls = {};

      for (final entry in _selectedFiles.entries) {
        if (entry.value != null) {
          final url = await _verificationService.uploadVerificationDocument(
            file: entry.value!,
            documentType: entry.key,
          );
          documentUrls[entry.key] = url;
        }
      }

      await _verificationService.saveVerificationDocuments(
        documentUrls: documentUrls,
      );

      if (mounted) {
        setState(() {
          _uploading = false;
          _uploadedUrls = documentUrls;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documents uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploading = false;
          _uploadError = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDocumentCard(String type, String title, String description) {
    final file = _selectedFiles[type];
    final hasUploaded = _uploadedUrls.containsKey(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (hasUploaded)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            if (file != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kIsWeb
                            ? (file as PlatformFile).name
                            : (file as File).path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedFiles[type] = null;
                        });
                      },
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _uploading ? null : () => _pickFile(type),
                icon: const Icon(Icons.upload_file),
                label: const Text('Select file'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Verification'),
        actions: [
          if (_uploading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Upload verification documents',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your ID, background check, and certificates to build trust with parents.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDocumentCard(
              'id',
              'Government ID',
              'Driver\'s license, passport, or national ID',
            ),
            _buildDocumentCard(
              'background_check',
              'Background Check',
              'Criminal background check certificate',
            ),
            _buildDocumentCard(
              'certificate',
              'Certificates',
              'CPR, first aid, or childcare certificates',
            ),
            if (_uploadError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _uploadError!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _uploading ? null : _uploadAllDocuments,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _uploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Uploading...'),
                      ],
                    )
                  : const Text('Upload Documents'),
            ),
          ],
        ),
      ),
    );
  }
}
