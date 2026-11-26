import 'dart:math' as math;

/// Rival de 4 en raya: minimax con poda alfa-beta.
///
/// El tablero es una matriz [filas][columnas] con 0 = vacío y el número de
/// cada jugador en sus fichas. La fila 0 es la de arriba.
class CuatroEnRayaAi {
  static const int rows = 6;
  static const int cols = 7;

  /// Columnas del centro hacia fuera: se exploran primero porque suelen ser
  /// mejores, y así la poda corta antes.
  static const List<int> _order = [3, 2, 4, 1, 5, 0, 6];

  static const int _winScore = 1000000;
  static const int _infinity = _winScore * 10;

  final int depth;
  final math.Random _random;

  CuatroEnRayaAi({this.depth = 7, math.Random? random})
    : _random = random ?? math.Random();

  /// Mejor columna para [me] contra [rival]. Si varias valen lo mismo,
  /// elige una al azar entre ellas para no jugar siempre igual.
  int chooseColumn(
    List<List<int>> board, {
    required int me,
    required int rival,
  }) {
    final grid = [for (final row in board) List<int>.of(row)];
    final moves = _validMoves(grid);
    if (moves.isEmpty) return 0;

    var best = -_infinity;
    final bestMoves = <int>[];
    for (final col in moves) {
      final row = _drop(grid, col, me);
      final score = _isWinAt(grid, row, col, me)
          ? _winScore + depth
          : -_negamax(grid, depth - 1, -_infinity, _infinity, rival, me);
      grid[row][col] = 0;
      if (score > best) {
        best = score;
        bestMoves
          ..clear()
          ..add(col);
      } else if (score == best) {
        bestMoves.add(col);
      }
    }
    return bestMoves[_random.nextInt(bestMoves.length)];
  }

  int _negamax(
    List<List<int>> grid,
    int depthLeft,
    int alpha,
    int beta,
    int player,
    int other,
  ) {
    final moves = _validMoves(grid);
    if (moves.isEmpty) return 0;

    // Ganar ya es lo mejor; cuanto antes, mejor (más profundidad restante).
    for (final col in moves) {
      final row = _drop(grid, col, player);
      final wins = _isWinAt(grid, row, col, player);
      grid[row][col] = 0;
      if (wins) return _winScore + depthLeft;
    }
    if (depthLeft == 0) return _evaluate(grid, player, other);

    var best = -_infinity;
    for (final col in moves) {
      final row = _drop(grid, col, player);
      final score =
          -_negamax(grid, depthLeft - 1, -beta, -alpha, other, player);
      grid[row][col] = 0;
      if (score > best) best = score;
      if (best > alpha) alpha = best;
      if (alpha >= beta) break;
    }
    return best;
  }

  List<int> _validMoves(List<List<int>> grid) => [
    for (final c in _order)
      if (grid[0][c] == 0) c,
  ];

  /// Deja caer la ficha y devuelve la fila donde queda.
  int _drop(List<List<int>> grid, int col, int player) {
    for (var row = rows - 1; row >= 0; row--) {
      if (grid[row][col] == 0) {
        grid[row][col] = player;
        return row;
      }
    }
    throw StateError('Columna $col llena');
  }

  static const List<(int, int)> _directions = [
    (0, 1),
    (1, 0),
    (1, 1),
    (1, -1),
  ];

  bool _isWinAt(List<List<int>> grid, int row, int col, int player) {
    for (final (dr, dc) in _directions) {
      var count = 1;
      for (final sign in const [1, -1]) {
        var r = row + dr * sign;
        var c = col + dc * sign;
        while (r >= 0 &&
            r < rows &&
            c >= 0 &&
            c < cols &&
            grid[r][c] == player) {
          count++;
          r += dr * sign;
          c += dc * sign;
        }
      }
      if (count >= 4) return true;
    }
    return false;
  }

  /// Puntúa todas las ventanas de 4 casillas: premia las que solo tienen
  /// fichas propias y castiga las del rival. El centro vale un poco más.
  int _evaluate(List<List<int>> grid, int player, int other) {
    var score = 0;
    for (var r = 0; r < rows; r++) {
      if (grid[r][3] == player) score += 3;
      if (grid[r][3] == other) score -= 3;
    }
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        for (final (dr, dc) in _directions) {
          final endR = r + dr * 3;
          final endC = c + dc * 3;
          if (endR < 0 || endR >= rows || endC < 0 || endC >= cols) continue;
          var mine = 0;
          var theirs = 0;
          for (var i = 0; i < 4; i++) {
            final v = grid[r + dr * i][c + dc * i];
            if (v == player) mine++;
            if (v == other) theirs++;
          }
          score += _window(mine, theirs);
        }
      }
    }
    return score;
  }

  int _window(int mine, int theirs) {
    if (mine > 0 && theirs > 0) return 0;
    if (mine == 3) return 50;
    if (mine == 2) return 10;
    if (theirs == 3) return -60;
    if (theirs == 2) return -12;
    return 0;
  }
}
