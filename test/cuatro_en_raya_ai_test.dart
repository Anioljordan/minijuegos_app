import 'dart:math' as math;

import 'package:cubo/core/cuatro_en_raya_ai.dart';
import 'package:flutter_test/flutter_test.dart';

const _human = 1;
const _machine = 2;

List<List<int>> _empty() => List.generate(6, (_) => List.filled(7, 0));

void _drop(List<List<int>> board, int col, int player) {
  for (var row = 5; row >= 0; row--) {
    if (board[row][col] == 0) {
      board[row][col] = player;
      return;
    }
  }
}

bool _hasFour(List<List<int>> b, int p) {
  for (var r = 0; r < 6; r++) {
    for (var c = 0; c < 7; c++) {
      for (final (dr, dc) in const [(0, 1), (1, 0), (1, 1), (1, -1)]) {
        var ok = true;
        for (var i = 0; i < 4; i++) {
          final rr = r + dr * i, cc = c + dc * i;
          if (rr < 0 || rr > 5 || cc < 0 || cc > 6 || b[rr][cc] != p) {
            ok = false;
            break;
          }
        }
        if (ok) return true;
      }
    }
  }
  return false;
}

void main() {
  final ai = CuatroEnRayaAi(random: math.Random(1));

  test('gana en cuanto puede', () {
    final board = _empty();
    for (final c in [0, 1, 2]) {
      _drop(board, c, _machine);
    }
    for (final c in [0, 1, 2]) {
      _drop(board, c, _human);
    }
    expect(ai.chooseColumn(board, me: _machine, rival: _human), 3);
  });

  test('bloquea tres en raya del rival', () {
    final board = _empty();
    // La máquina ya tapa la columna 0; solo queda la amenaza en la 4.
    _drop(board, 0, _machine);
    for (final c in [1, 2, 3]) {
      _drop(board, c, _human);
    }
    _drop(board, 1, _machine);
    expect(ai.chooseColumn(board, me: _machine, rival: _human), 4);
  });

  test('corta dos seguidas abiertas abajo antes de que sean imparables', () {
    // Humano en 2 y 3 de la fila de abajo, máquina encima del 3.
    final board = _empty();
    _drop(board, 3, _human);
    _drop(board, 3, _machine);
    _drop(board, 2, _human);
    final col = ai.chooseColumn(board, me: _machine, rival: _human);
    expect([1, 4], contains(col));
  });

  test('no pierde contra la estrategia de tirar todo en horizontal', () {
    // El humano empieza y va rellenando la fila de abajo de izquierda a
    // derecha desde cada columna inicial posible.
    for (var start = 0; start < 7; start++) {
      final board = _empty();
      var humanWon = false;
      var next = start;
      for (var turn = 0; turn < 21; turn++) {
        var col = next % 7;
        while (board[0][col] != 0) {
          col = (col + 1) % 7;
        }
        _drop(board, col, _human);
        next = col + 1;
        if (_hasFour(board, _human)) {
          humanWon = true;
          break;
        }
        final reply = ai.chooseColumn(board, me: _machine, rival: _human);
        _drop(board, reply, _machine);
        if (_hasFour(board, _machine)) break;
      }
      expect(humanWon, isFalse, reason: 'empezando en la columna $start');
    }
  });

  test('piensa rápido en el tablero vacío', () {
    final sw = Stopwatch()..start();
    ai.chooseColumn(_empty(), me: _machine, rival: _human);
    expect(sw.elapsedMilliseconds, lessThan(1500));
  });
}
