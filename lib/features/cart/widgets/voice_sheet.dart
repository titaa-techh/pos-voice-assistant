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
  List<MapEntry<ProductModel, int>> _ranked = [];

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _listen() async {
    setState(() => _listening = true);
    final ok = await _voice.listen(onResult: (t) {
      if (!mounted) return;
      _text.text = t;
      setState(() => _listening = false);
      _match(t);
    });
    if (!ok && mounted) {
      setState(() => _listening = false);
      _snack('Suara tidak tersedia. Ketik nama produk.');
    }
  }

  void _match(String q) {
    if (q.trim().isEmpty) {
      _snack('Suara tidak terdengar, coba lagi.');
      return;
    }
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
    _voice.stop();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final th = ref.watch(thresholdProvider);
    final hasBest = _ranked.isNotEmpty && _ranked.first.value <= th;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Ucapkan nama produk', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        IconButton.filled(
          iconSize: 36,
          tooltip: 'Mulai mendengarkan',
          onPressed: _listening ? null : _listen,
          icon: Icon(_listening ? Icons.hearing : Icons.mic),
        ),
        Text(_listening ? 'Mendengarkan...' : 'Ketuk mikrofon, atau ketik di bawah'),
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
