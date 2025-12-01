import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';

typedef OnCardTap = void Function(CardComponent card);

class CardComponent extends PositionComponent with TapCallbacks {
  final int pairId;
  final Sprite frontSprite;
  final Sprite backSprite;
  bool isFaceUp = false;
  bool isMatched = false;
  final OnCardTap onTap;

  late SpriteComponent _spriteComponent;

  CardComponent({
    required this.pairId,
    required this.frontSprite,
    required this.backSprite,
    required Vector2 position,
    required Vector2 size,
    required this.onTap,
  }) : super(position: position, size: size, anchor: Anchor.topLeft) {
    _spriteComponent =
        SpriteComponent(sprite: backSprite, size: size, anchor: Anchor.topLeft);
  }

  @override
  Future<void> onLoad() async {
    add(_spriteComponent);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isMatched || isFaceUp) return;
    onTap(this);
  }

  /// Reveal front sprite with flip animation
  void reveal({double duration = 0.18}) {
    if (isFaceUp || isMatched) return;

    _spriteComponent.add(
      ScaleEffect.to(
        Vector2(0, _spriteComponent.scale.y),
        EffectController(duration: duration),
        onComplete: () {
          _spriteComponent.sprite = frontSprite;
          isFaceUp = true;

          _spriteComponent.add(
            ScaleEffect.to(
              Vector2(1, _spriteComponent.scale.y),
              EffectController(duration: duration),
            ),
          );
        },
      ),
    );
  }

  /// Hide front sprite with flip animation
  void hide({double duration = 0.18}) {
    if (!isFaceUp || isMatched) return;

    _spriteComponent.add(
      ScaleEffect.to(
        Vector2(0, _spriteComponent.scale.y),
        EffectController(duration: duration),
        onComplete: () {
          _spriteComponent.sprite = backSprite;
          isFaceUp = false;

          _spriteComponent.add(
            ScaleEffect.to(
              Vector2(1, _spriteComponent.scale.y),
              EffectController(duration: duration),
            ),
          );
        },
      ),
    );
  }

  /// Small "pop" when matched
  void match({double duration = 0.25}) {
    isMatched = true;

    _spriteComponent.add(
      ScaleEffect.to(
        Vector2.all(1.05),
        EffectController(duration: duration),
        onComplete: () {
          _spriteComponent.add(
            ScaleEffect.to(
              Vector2.all(1.0),
              EffectController(duration: duration),
            ),
          );
        },
      ),
    );
  }
}