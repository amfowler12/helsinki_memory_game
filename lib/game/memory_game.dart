import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/card_component.dart';

typedef GameOverCallback =
    void Function(bool won, int score, int matches, int mismatches);

class MemoryGame extends FlameGame {
  final int levelId;
  final int rows;
  final int cols;
  final int timeLimit;
  final GameOverCallback onGameOver;

  @override
  late final World world;

  late Vector2 cardSize;
  int score = 0;
  int timeLeft = 0;
  int remainingPairs = 0;
  int matchesCount = 0;
  int mismatchesCount = 0;
  bool running = true;

  CardComponent? firstCard;
  CardComponent? secondCard;

  final TextComponent timerText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  final TextComponent scoreText = TextComponent(
    text: '',
    textRenderer: TextPaint(
      style: const TextStyle(
        fontSize: 18,
        color: Colors.amber,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  final RectangleComponent boardPanel = RectangleComponent(
    size: Vector2.zero(),
    paint: Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.9)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
  );

  final List<CardComponent> cards = [];

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
  Color backgroundColor() => const Color(0xFF0F172A);

  void _updateHud() {
    timerText.text = 'Time: $timeLeft s';
    scoreText.text = 'Score: $score';
  }

  Map<String, Object> _computeGridLayout(Vector2 viewportSize, int totalCards) {
    const double gap = 16.0;
    const double padding = 40.0;
    final gridWidth = viewportSize.x - padding * 2;
    final gridHeight = viewportSize.y - 180.0;
    const double aspect = 2.0 / 3.0;

    final int maxCols = min(totalCards, 7);
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
    final startY = (viewportSize.y - totalGridHeight) / 2.0 + 20.0;

    return {
      'cols': bestCols,
      'rows': bestRows,
      'cardSize': cardSize,
      'startX': startX,
      'startY': startY,
      'gap': gap,
      'boardWidth': totalGridWidth,
      'boardHeight': totalGridHeight,
    };
  }

  void _layoutHud(Vector2 view) {
    timerText
      ..anchor = Anchor.topCenter
      ..position = Vector2(view.x / 2, 24);
    scoreText
      ..anchor = Anchor.topCenter
      ..position = Vector2(view.x / 2, 52);
  }

  void _layoutBoard(Vector2 view) {
    if (cards.isEmpty) return;

    final layout = _computeGridLayout(view, cards.length);
    final int gridCols = layout['cols'] as int;
    final double gap = layout['gap'] as double;
    final Vector2 cardSz = layout['cardSize'] as Vector2;
    final double startX = layout['startX'] as double;
    final double startY = layout['startY'] as double;
    final double boardWidth = layout['boardWidth'] as double;
    final double boardHeight = layout['boardHeight'] as double;

    cardSize = cardSz;

    boardPanel
      ..size = Vector2(boardWidth + 40, boardHeight + 40)
      ..anchor = Anchor.center
      ..position = Vector2(view.x / 2, startY + boardHeight / 2);

    for (int i = 0; i < cards.length; i++) {
      final r = i ~/ gridCols;
      final c = i % gridCols;
      cards[i]
        ..position = Vector2(
          startX + c * (cardSz.x + gap),
          startY + r * (cardSz.y + gap),
        )
        ..updateSize(cardSz);
    }
  }

  void _layoutAll(Vector2 view) {
    _layoutHud(view);
    _layoutBoard(view);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layoutAll(size);
  }

  @override
  Future<void> onLoad() async {
    world = World();
    add(world);

    final view = size;

    add(timerText);
    add(scoreText);
    add(boardPanel);

    score = 0;
    timeLeft = timeLimit;
    remainingPairs = (levelId == 1)
        ? 4
        : (levelId == 2)
        ? 6
        : 7;
    matchesCount = 0;
    mismatchesCount = 0;
    running = true;
    _updateHud();

    final rng = Random();
    final candidates = List<String>.from(assetNames);
    while (candidates.length < remainingPairs) {
      candidates.addAll(assetNames);
    }
    candidates.shuffle(rng);

    final selected = candidates.take(remainingPairs).toList();
    final imgs = <String>[];
    for (final s in selected) {
      imgs
        ..add(s)
        ..add(s);
    }
    imgs.shuffle(rng);

    final preload = imgs.toSet().toList()..add(backAsset);
    for (final img in preload) {
      await images.load(img);
    }

    final layout = _computeGridLayout(view, imgs.length);
    final int gridCols = layout['cols'] as int;
    final double gap = layout['gap'] as double;
    final Vector2 cardSz = layout['cardSize'] as Vector2;
    final double startX = layout['startX'] as double;
    final double startY = layout['startY'] as double;
    final double boardWidth = layout['boardWidth'] as double;
    final double boardHeight = layout['boardHeight'] as double;

    cardSize = cardSz;

    boardPanel
      ..size = Vector2(boardWidth + 40, boardHeight + 40)
      ..anchor = Anchor.center
      ..position = Vector2(view.x / 2, startY + boardHeight / 2);

    for (int i = 0; i < imgs.length; i++) {
      final r = i ~/ gridCols;
      final c = i % gridCols;
      final asset = imgs[i];

      final card = CardComponent(
        pairId: selected.indexOf(asset),
        frontSprite: Sprite(images.fromCache(asset)),
        backSprite: Sprite(images.fromCache(backAsset)),
        position: Vector2(
          startX + c * (cardSz.x + gap),
          startY + r * (cardSz.y + gap),
        ),
        size: cardSz.clone(),
        onTap: _onCardTap,
      );

      add(card);
      cards.add(card);
    }

    world.add(
      TimerComponent(
        period: 1,
        repeat: true,
        onTick: () {
          if (!running) return;
          timeLeft--;
          _updateHud();
          if (timeLeft <= 0) {
            running = false;
            onGameOver(false, score, matchesCount, mismatchesCount);
          }
        },
      ),
    );

    _layoutAll(view);
  }

  void _onCardTap(CardComponent card) {
    if (!running) return;
    if (card.isFaceUp || card.isMatched) return;

    card.reveal();

    if (firstCard == null) {
      firstCard = card;
      return;
    }

    if (secondCard == null) {
      secondCard = card;

      if (firstCard!.pairId == secondCard!.pairId) {
        firstCard!.match();
        secondCard!.match();
        remainingPairs--;
        score += 100;
        matchesCount++;
        _updateHud();

        firstCard = null;
        secondCard = null;

        if (remainingPairs == 0) {
          running = false;
          onGameOver(true, score, matchesCount, mismatchesCount);
        }
      } else {
        score = max(0, score - 10);
        mismatchesCount++;
        _updateHud();

        Future.delayed(const Duration(milliseconds: 700), () {
          firstCard?.hide();
          secondCard?.hide();
          firstCard = null;
          secondCard = null;
        });
      }
    }
  }
}
