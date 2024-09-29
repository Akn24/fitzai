import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;

  Future<void> initialize() async {
    bool available = await _speechToText.initialize(
      onError: _onError,
      onStatus: _onStatus,
    );
    if (available) {
      print('Speech recognition initialized and ready.');
    } else {
      print('Speech recognition unavailable.');
    }
  }

  void listenForCommands(Function(String) onCommandDetected) {
    if (!_isListening) {
      _speechToText.listen(
        onResult: (result) => _onResult(result, onCommandDetected),
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 5),
        localeId: 'en_US',
        partialResults: true,
      );
      _isListening = true;
      print('Starting to listen...');
    }
  }

  void stopListening() {
    if (_isListening) {
      _speechToText.stop();
      _isListening = false;
      print('Stopped listening.');
    }
  }

  void _onResult(
      SpeechRecognitionResult result, Function(String) onCommandDetected) {
    print('Detected speech: ${result.recognizedWords}');
    onCommandDetected(result.recognizedWords.toLowerCase());
    stopListening();
  }

  void _onError(SpeechRecognitionError error) {
    print('Speech recognition error: ${error.errorMsg}');
    stopListening();
  }

  void _onStatus(String status) {
    print('Speech Status: $status');
    if (status == 'done') {
      stopListening();
    }
  }
}
