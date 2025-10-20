import 'package:flutter_test/flutter_test.dart';
import 'package:tuang/services/audio_service.dart';

void main() {
  group('AudioService', () {
    test('setMuted toggles and sfx updates lastSfxPlayed', () async {
      AudioService.testMode = true; // skip plugin init in tests
      final audio = AudioService.I;
      await audio.init();
      audio.setMuted(false);
      audio.playCoin();
      expect(audio.lastSfxPlayed, 'coin.wav');

      audio.setMuted(true);
      audio.playHit();
      expect(audio.lastSfxPlayed, 'hit.wav');
      expect(audio.muted, isTrue);
    });
  });
}
