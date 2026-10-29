
import 'package:speech_to_text/speech_to_text.dart';

/// Pembungkus speech_to_text. Di Chrome memakai Web Speech API,
/// sehingga memerlukan izin mikrofon dan koneksi internet.
class VoiceService {
  final SpeechToText _speech = SpeechToText();
  bool _ready = false;
  String? _localeId;
  void Function(String status)? _onStatus;
  void Function(String error)? _onError;

  /// Locale yang dipakai (mis. id-ID atau id_ID), null bila memakai bawaan perangkat.
  String? get localeId => _localeId;

  /// Menyiapkan layanan. Mengembalikan null bila siap, atau pesan galat.
  Future<String?> init({
    required void Function(String status) onStatus,
    required void Function(String error) onError,
  }) async {
    _onStatus = onStatus;
    _onError = onError;

    if (_ready) return null;

    try {
      _ready = await _speech.initialize(
        onStatus: (s) => _onStatus?.call(s),
        onError: (e) => _onError?.call(e.errorMsg),
      );
    } catch (e) {
      return 'Pengenalan suara tidak tersedia: $e';
    }

    if (!_ready) {
      return 'Izin mikrofon ditolak atau browser tidak mendukung pengenalan suara.';
    }

    final locales = await _speech.locales();

    for (final l in locales) {
      final id = l.localeId.toLowerCase().replaceAll('-', '_');

      if (id == 'id_id') {
        _localeId = l.localeId;
        break;
      }
    }

    if (_localeId == null) {
      for (final l in locales) {
        if (l.localeId.toLowerCase().startsWith('id')) {
          _localeId = l.localeId;
          break;
        }
      }
    }

    return null;
  }

  /// Mulai mendengarkan.
  /// onResult menerima teks sementara dan teks final.
  
Future<void> listen({
  required void Function(String text, bool isFinal) onResult,
}) async {
  await _speech.listen(
    listenOptions: SpeechListenOptions(
      localeId: _localeId,
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    ),
    onResult: (result) {
      onResult(result.recognizedWords, result.finalResult);
    },
  );


  }

  Future<void> stop() => _speech.stop();

  Future<void> cancel() => _speech.cancel();
}
