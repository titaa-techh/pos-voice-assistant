import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _ready = false;

  /// false bila izin mikrofon ditolak atau perangkat tidak mendukung.
  Future<bool> listen({required void Function(String text) onResult}) async {
    if (!_ready) _ready = await _speech.initialize();
    if (!_ready) return false;
    await _speech.listen(
      localeId: 'id_ID',
      onResult: (r) {
        if (r.finalResult) onResult(r.recognizedWords);
      },
    );
    return true;
  }

  Future<void> stop() => _speech.stop();
}
