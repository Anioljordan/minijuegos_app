import 'package:flutter/material.dart';

class ColorDuelPlayer {
  final String name;
  int score;

  ColorDuelPlayer({
    required this.name,
    this.score = 0,
  });
}

class ColorDuelGameState {
  int currentRound;
  int totalRounds;

  Color targetColor;

  List<ColorDuelPlayer> players;

  ColorDuelGameState({
    required this.players,
    required this.totalRounds,
    required this.targetColor,
    this.currentRound = 1,
  });
}