import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'card_component.dart';

typedef GameOverCallback = void Function(bool won, int score, int matches, int mismatches);

class MemoryGame extends FlameGame
    with KeyboardEvents {
  final int levelId;
  final int rows;
  final int cols;
  final int timeLimit;
  final GameOverCallback onGameOver;

  // Camera + world
  @override
  late final World world;

  late Vector2 cardSize;
  int remainingPairs = 0;
  int score = 0;
  int matchesCount = 0;
  int mismatchesCount = 0;
  int timeLeft = 0;
  bool running = true;

  CardComponent? _firstCard;
  CardComponent? _secondCard;

  late TextComponent _timerText;
  late TextComponent _scoreText;
  
  List<CardComponent> cards = [];

  void _updateHud() {
    _timerText.text = 'Time: $timeLeft';
    _scoreText.text = 'Score: $score';
  }

  // Compute a grid layout for a given viewport and total card count.
  // Returns a map with keys: 'cols','rows','cardSize','startX','startY','gap'
  Map<String, Object> _computeGridLayout(Vector2 viewportSize, int totalCards) {
    final double gap = 12.0;
    final double padding = 20.0;
    final gridWidth = viewportSize.x - padding * 2;
    // reserve a bit of vertical space for UI at top
    final gridHeight = viewportSize.y - 140.0;

    const double aspect = 2.0 / 3.0;

    final int maxCols = min(totalCards, 6);
    int bestCols = 1;
    int bestRows = (totalCards / bestCols).ceil();
    double bestCardWidth = 0.0;

    for (int tryCols = 1; tryCols <= maxCols; tryCols++) {
      final tryRows = (totalCards / tryCols).ceil();
      final cellMaxW = (gridWidth - (tryCols - 1) * gap) / tryCols;
      final cellMaxH = (gridHeight - (tryRows - 1) * gap) / tryRows;
      final tryCardW = min(cellMaxW, cellMaxH * aspect);
      if (tryCardW > bestCardWidth) {
        bestCardWidth = tryCardW;
        bestCols = tryCols;
        bestRows = tryRows;
      }
    }

    final cardWidth = bestCardWidth;
    final cardHeight = cardWidth / aspect;
    final cardSize = Vector2(cardWidth, cardHeight);

    final totalGridWidth = bestCols * cardWidth + (bestCols - 1) * gap;
    final totalGridHeight = bestRows * cardHeight + (bestRows - 1) * gap;
    final startX = (viewportSize.x - totalGridWidth) / 2.0;
    final startY = padding + (gridHeight - totalGridHeight) / 2.0;

    return {
      'cols': bestCols,
      'rows': bestRows,
      'cardSize': cardSize,
      'startX': startX,
      'startY': startY,
      'gap': gap,
    };
  }
  
  // Your image names
  final List<String> assetNames = [
    'helsinki_train.jpg',
    'helsinki_park.jpg',
    'helsinki_senate.jpg',
    'helsinki_port.jpg',
    'helsinki_tuomiokirkko.jpg',
    'helsinki_suomenlinna.jpg',
    'helsinki_market.jpg',
    'helsinki_church.jpg',
    'helsinki_aalto.jpg',
    'helsinki_cinnamon.jpg',
    'helsinki_karelian.jpg',
    'helsinki_sauna.png',
    'helsinki_oodi.jpg',
    'helsinki_marimekko.jpg',
  ];

  final String backAsset = 'back_card.png';
  
  MemoryGame({
    required this.levelId,
    required this.rows,
    required this.cols,
    required this.timeLimit,
    required this.onGameOver,
  });

  @override
  Color backgroundColor() => const Color(0xFFE2EFFA);

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    
    if (isMounted) {
      _timerText.position = Vector2(12, 12);
      _scoreText.position = Vector2(newSize.x - 12, 12);
    }
    
    // Recalculate and reposition cards if they exist
    if (cards.isEmpty) return;
    final layout = _computeGridLayout(newSize, cards.length);
    final int gridCols = layout['cols'] as int;
    final double gap = layout['gap'] as double;
    final Vector2 cardSz = layout['cardSize'] as Vector2;
    final double startX = layout['startX'] as double;
    final double startY = layout['startY'] as double;

    cardSize = cardSz;

    // Reposition all cards
    for (int i = 0; i < cards.length; i++) {
      final r = i ~/ gridCols;
      final c = i % gridCols;
      cards[i].position = Vector2(
        startX + c * (cardSz.x + gap),
        startY + r * (cardSz.y + gap),
      );
      cards[i].size = cardSize;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world = World();
    add(world);

    //
    // 1. Create world + responsive camera
    //
    final viewportSize = size;
    _timerText = TextComponent(
      text: "Time: 0",
      position: Vector2(12, 12),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 22, color: Colors.black87),
      ),
    );

    _scoreText = TextComponent(
      text: "Score: 0",
      position: Vector2(viewportSize.x - 12, 12),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 22, color: Colors.black87),
      ),
    );
 
    add(_timerText);
    add(_scoreText);
 
    //
    // 3. Timing + scoring setup
    //

    // Map levelId -> pairs: 1 = easy, 2 = medium, 3 = hard
    // Ensure Medium (id==2) yields 6 pairs (12 cards)
    final int desiredPairs =
      (levelId == 1) ? 3 : (levelId == 2) ? 6 : 7;

    // Ensure we create exactly desiredPairs * 2 cards for the chosen difficulty.
    final pairsNeeded = desiredPairs;
    remainingPairs = pairsNeeded;
    matchesCount = 0;
    mismatchesCount = 0;
    timeLeft = timeLimit;
    score = 0;
    _updateHud();
 
    //
    // 4. Pick random asset pairs
    //
    final rng = Random();
    final candidates = List<String>.from(assetNames);

    // If fewer unique images than needed, duplicate
    while (candidates.length < pairsNeeded) {
      candidates.addAll(assetNames);
    }

    candidates.shuffle(rng);
    final selected = candidates.take(pairsNeeded).toList();

    // two copies of each
    final cardImages = <String>[];
    for (final s in selected) {
      cardImages.add(s);
      cardImages.add(s);
    }
    cardImages.shuffle(rng);

    //
    // 5. Preload all images
    //
    final preload = cardImages.toSet().toList()..add(backAsset);
    for (final a in preload) {
      await images.load(a);
    }

    //
    // 6. Card layout inside viewport (maximize card size, centered)
    //
    // Compute layout for cards
    final int totalCards = pairsNeeded * 2;
    final layout = _computeGridLayout(viewportSize, totalCards);
    final int bestCols = layout['cols'] as int;
    final double gap = layout['gap'] as double;
    final Vector2 sz = layout['cardSize'] as Vector2;
    final double startX = layout['startX'] as double;
    final double startY = layout['startY'] as double;

    cardSize = sz;


    //
    // 7. Create card components
    //
    int index = 0;
    for (int i = 0; i < totalCards; i++) {
      final r = i ~/ bestCols;
      final c = i % bestCols;

      final asset = cardImages[index++];
      final card = CardComponent(
        pairId: selected.indexOf(asset),
        frontSprite: Sprite(images.fromCache(asset)),
        backSprite: Sprite(images.fromCache(backAsset)),
        position: Vector2(
          startX + c * (sz.x + gap),
          startY + r * (sz.y + gap),
        ),
        size: sz.clone(),
        onTap: handleCardTap,
      );
      add(card);
      cards.add(card);
    }

    //
    // 8. Countdown timer
    //
    world.add(
      TimerComponent(
        period: 1,
        repeat: true,
        onTick: () {
          if (!running) return;
          timeLeft -= 1;
          _timerText.text = 'Time: $timeLeft';
          if (timeLeft <= 0) {
            running = false;
            onGameOver(false, score, matchesCount, mismatchesCount);
          }
        },
      ),
    );
  }
 
  //
  // 9. Card tap logic
  void handleCardTap(CardComponent card) {
  if (!running) return;
  if (card.isFaceUp || card.isMatched) return;
 
  card.reveal();
 
  // First card flipped
  if (_firstCard == null) {
    _firstCard = card;
    return;
  }
 
  // Second card flipped
  if (_secondCard == null) {
    _secondCard = card;
 
    if (_firstCard!.pairId == _secondCard!.pairId) {
      // MATCH
      _firstCard!.match();
      _secondCard!.match();
      remainingPairs -= 1;
      score += 100;
    matchesCount += 1;
     _updateHud();
 
      _firstCard = null;
      _secondCard = null;
 
      if (remainingPairs <= 0) {
        running = false;
        onGameOver(true, score, matchesCount, mismatchesCount);
      }
    } else {
      // NOT A MATCH
      // Apply score penalty and increment mismatch counter immediately
      score = max(0, score - 10);
      mismatchesCount += 1;
      _updateHud();

      Future.delayed(Duration(milliseconds: 700), () {
        _firstCard!.hide();
        _secondCard!.hide();

        _firstCard = null;
        _secondCard = null;
      });
    }
  }
  }
}