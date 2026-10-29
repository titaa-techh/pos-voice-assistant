import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/utils/levenshtein.dart';
import '../../product/models/product_model.dart';
import '../../product/providers/product_provider.dart';
import '../providers/cart_provider.dart';

void showVoiceSheet(BuildContext context) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const VoiceSheet(),
    );

class VoiceSheet extends ConsumerStatefulWidget {
  const VoiceSheet({super.key});
  @override
  ConsumerState<VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends ConsumerState<VoiceSheet> {
  final _voice = VoiceService();
  final _text = TextEditingController();
  bool _listening = false;
  bool _matched = false;
  String? _error;
  List<MapEntry<ProductModel, int>> _ranked = [];

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  String _friendly(String code) {
    final c = code.toLowerCase();
    if (c.contains('no_match') || c.contains('no-speech') || c.contains('no_speech')) {
      return 'Suara tidak terdengar. Bicara lebih dekat ke mikrofon, lalu jeda 1 sampai 2 detik setelah selesai.';
    }
    if (c.contains('not-allowed') || c.contains('permission')) {
      return 'Izin mikrofon ditolak. Klik ikon gembok di address bar, izinkan Mikrofon, lalu muat ulang.';
    }
    if (c.contains('network')) {
      return 'Pengenalan suara di Chrome memerlukan koneksi internet.';
    }
    if (c.contains('audio') || c.contains('capture')) {
      return 'Mikrofon tidak ditemukan atau sedang dipakai aplikasi lain.';
    }
    return 'Galat suara: $code';
  }

  void _onStatus(String status) {
    if (!mounted) return;
    if (status == 'done' || status == 'notListening') {
      setState(() => _listening = false);
      final t = _text.text.trim();
      if (t.isEmpty && _error == null) {
        setState(() => _error =
            'Suara tidak terdengar. Bicara lebih dekat ke mikrofon, lalu jeda 1 sampai 2 detik setelah selesai.');
      } else if (t.isNotEmpty && !_matched) {
        _match(t);
      }
    }
  }

  void _onError(String code) {
    if (!mounted) return;
    setState(() {
      _listening = false;
      _error = _friendly(code);
    });
  }

  Future<void> _toggleListen() async {
    if (_listening) {
      await _voice.stop();
      return;
    }
    final err = await _voice.init(onStatus: _onStatus, onError: _onError);
    if (!mounted) return;
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _listening = true;
      _matched = false;
      _error = null;
      _ranked = [];
      _text.clear();
    });
    await _voice.listen(onResult: (t, isFinal) {
      if (!mounted) return;
      _text.text = t;
      _text.selection = TextSelection.collapsed(offset: t.length);
      if (isFinal && t.trim().isNotEmpty) {
        setState(() => _listening = false);
        _match(t);
      }
    });
  }

  void _match(String q) {
    if (q.trim().isEmpty) {
      _snack('Suara tidak terdengar, coba lagi.');
      return;
    }
    _matched = true;
    setState(() => _ranked =
        rankByDistance(q, ref.read(productsProvider), (p) => p.name));
  }

  void _pick(ProductModel p) {
    final err = ref.read(cartProvider.notifier).add(p);
    if (err != null) {
      _snack(err);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _voice.cancel();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final th = ref.watch(thresholdProvider);
    final hasBest = _ranked.isNotEmpty && _ranked.first.value <= th;
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Ucapkan nama produk', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        IconButton.filled(
          iconSize: 36,
          tooltip: _listening ? 'Berhenti mendengarkan' : 'Mulai mendengarkan',
          onPressed: _toggleListen,
          icon: Icon(_listening ? Icons.stop : Icons.mic),
        ),
        const SizedBox(height: 4),
        Text(_listening
            ? 'Mendengarkan... bicara sekarang, lalu jeda sebentar'
            : 'Ketuk mikrofon, atau ketik di bawah'),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.error)),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: _text,
          onSubmitted: _match,
          decoration: InputDecoration(
            labelText: 'Hasil ucapan',
            suffixIcon: IconButton(
              tooltip: 'Cocokkan',
              icon: const Icon(Icons.search),
              onPressed: () => _match(_text.text),
            ),
          ),
        ),
        if (_ranked.isNotEmpty) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(hasBest
                ? 'Cocok: ${_ranked.first.key.name} (jarak ${_ranked.first.value}, ambang $th)'
                : 'Tidak ada yang cocok pada ambang $th. Pilih dari saran:'),
          ),
          for (final e in _ranked.take(4))
            ListTile(
              title: Text(e.key.name),
              trailing: Text('jarak ${e.value}'),
              selected: hasBest && e == _ranked.first,
              onTap: () => _pick(e.key),
            ),
        ],
      ]),
    );
  }
}
