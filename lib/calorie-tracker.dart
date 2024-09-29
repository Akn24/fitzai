import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CalorieTracker extends StatefulWidget {
  final Function(double, double, double) onNutrientsExtracted;

  const CalorieTracker({super.key, required this.onNutrientsExtracted});

  @override
  _CalorieTrackerState createState() => _CalorieTrackerState();
}

class _CalorieTrackerState extends State<CalorieTracker> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String _extractedText = '';
  bool _isProcessing = false;

  double protein = 0.0;
  double carbs = 0.0;
  double fat = 0.0;

  @override
  void initState() {
    super.initState();
    // Initial setup
    print('CalorieTracker initialized');
  }

  Future<void> _pickImageFromCamera() async {
    final PickedFile? pickedFile =
        await _picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isProcessing = true;
      });
      print('Image picked from camera: ${pickedFile.path}');
      await _performTextRecognition(File(pickedFile.path));
    } else {
      print('No image picked.');
    }
  }

  Future<void> _performTextRecognition(File imageFile) async {
    try {
      print('Performing text recognition...');
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text;
        _isProcessing = false;
      });

      print('Recognized text: $_extractedText');
      _extractNutrients(_extractedText);
      textRecognizer.close();
    } catch (e) {
      print('Error during text recognition: $e');
    }
  }

  void _extractNutrients(String text) {
    // Clean the text for better extraction
    text = text.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');
    print('Cleaned text: $text');

    setState(() {
      // Extract only the relevant nutrients
      protein = _extractValue(text, 'Protein');
      carbs = _extractValue(
          text, 'Total Carbohydrate'); // Change to match the format
      fat = _extractValue(text, 'Total Fat');
    });

    print('Extracted values - Protein: $protein, Carbs: $carbs, Fat: $fat');
  }

  double _extractValue(String text, String nutrient) {
    // Adjusted regex to capture nutrients with or without the colon
    RegExp regex =
        RegExp(r'' + nutrient + r'\s*(\d+\.?\d*)\s*g', caseSensitive: false);
    Match? match = regex.firstMatch(text);

    if (match != null) {
      print('Extracted $nutrient value: ${match.group(1)}g');
      return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }

    print('No match found for $nutrient');
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    print("CalorieTracker build method called");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Calories'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.onNutrientsExtracted(protein, carbs, fat);
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_imageFile != null)
              Column(
                children: [
                  Image.file(
                    _imageFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 10),
                  if (_isProcessing)
                    const CircularProgressIndicator()
                  else
                    _buildNutrientOutput(),
                ],
              )
            else
              const Text(
                'No image selected.',
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImageFromCamera,
              child: const Text('Take a Photo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientOutput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Extracted Nutritional Facts:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildNutrientRow('Protein', protein),
        _buildNutrientRow('Carbohydrates', carbs),
        _buildNutrientRow('Fat', fat),
      ],
    );
  }

  Widget _buildNutrientRow(String nutrient, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$nutrient:',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          '$value g',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
