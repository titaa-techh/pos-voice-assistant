import 'package:flutter_test/flutter_test.dart';
import 'package:pos_voice_assistant/core/utils/levenshtein.dart';

void main() {
  test('jarak identik adalah 0', () {
    expect(levenshtein('Teh Botol', 'teh botol'), 0);
  });

  test('indomi goreng ke Indomie Goreng berjarak 1', () {
    expect(levenshtein('indomi goreng', 'Indomie Goreng'), 1);
  });

  test('string kosong berjarak sepanjang string lain', () {
    expect(levenshtein('', 'gula'), 4);
    expect(levenshtein('gula', ''), 4);
  });

  test('rankByDistance mengurutkan dari yang paling mirip', () {
    final r = rankByDistance<String>(
        'teh botl', ['Gula Pasir', 'Teh Botol', 'Kopi'], (s) => s);
    expect(r.first.key, 'Teh Botol');
    expect(r.first.value, 1);
  });
}
