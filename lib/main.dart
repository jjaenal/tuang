import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/my_game.dart';
import 'ui/main_menu.dart';
import 'ui/game_over.dart';
import 'ui/hud_overlay.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state/app_settings_cubit.dart';
import 'services/ad_service.dart';
import 'services/audio_service.dart';
import 'services/haptics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AudioService.I.init(); // inisialisasi BGM channel
  final MyGame game = MyGame();
  runApp(MyApp(game: game));
}

class MyApp extends StatelessWidget {
  final MyGame game;
  const MyApp({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppSettingsCubit>(
          create: (_) => AppSettingsCubit()..load(),
        ), // load state tersimpan dari SharedPreferences
      ],
      child: BlocListener<AppSettingsCubit, AppSettingsState>(
        listenWhen:
            (prev, curr) =>
                prev.paused != curr.paused ||
                prev.adsEnabled != curr.adsEnabled ||
                prev.consentGiven != curr.consentGiven ||
                prev.audioOn != curr.audioOn ||
                prev.npaEnabled != curr.npaEnabled ||
                prev.hapticsOn != curr.hapticsOn,
        listener: (context, state) {
          if (state.paused) {
            game.pauseEngine();
          } else {
            game.resumeEngine();
          }
          // Inisialisasi iklan hanya saat pengguna memberi consent dan Ads diaktifkan
          if (state.consentGiven && state.adsEnabled) {
            AdService.I.init();
          }
          // Sinkronkan preferensi NPA ke AdService
          AdService.I.setNonPersonalizedAds(state.npaEnabled);
          // Sinkronkan toggle audio dengan AudioService (mute bila audioOff) dan mulai BGM bila audioOn
          AudioService.I.setMuted(!state.audioOn);
          if (state.audioOn) {
            AudioService.I.startBgm();
          }
          // Sinkronkan toggle haptics
          HapticsService.enabled = state.hapticsOn;
        },
        child: MaterialApp(
          title: 'Tuang Game',
          theme: ThemeData.dark(),
          home: Scaffold(
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                final delta = details.delta;
                final dir = Vector2(delta.dx, delta.dy);
                if (dir.length2 > 0) {
                  dir.normalize();
                  game.inputDir = dir;
                }
              },
              onPanEnd: (_) => game.inputDir = Vector2.zero(),
              child: KeyboardListener(
                focusNode: FocusNode(),
                autofocus: true,
                onKeyEvent: (KeyEvent event) {
                  // Gunakan API keyboard baru (HardwareKeyboard) sesuai deprecation Flutter 3.18+
                  final pressed = HardwareKeyboard.instance.logicalKeysPressed;
                  final dir = Vector2.zero();
                  if (pressed.contains(LogicalKeyboardKey.keyA) ||
                      pressed.contains(LogicalKeyboardKey.arrowLeft)) {
                    dir.x -= 1;
                  }
                  if (pressed.contains(LogicalKeyboardKey.keyD) ||
                      pressed.contains(LogicalKeyboardKey.arrowRight)) {
                    dir.x += 1;
                  }
                  if (pressed.contains(LogicalKeyboardKey.keyW) ||
                      pressed.contains(LogicalKeyboardKey.arrowUp)) {
                    dir.y -= 1;
                  }
                  if (pressed.contains(LogicalKeyboardKey.keyS) ||
                      pressed.contains(LogicalKeyboardKey.arrowDown)) {
                    dir.y += 1;
                  }
                  game.inputDir = dir;
                },
                child: GameWidget(
                  game: game,
                  overlayBuilderMap: {
                    MyGame.overlayMainMenu:
                        (context, g) => MainMenuOverlay(game: g as MyGame),
                    MyGame.overlayHud:
                        (context, g) => HudOverlay(game: g as MyGame),
                    MyGame.overlayGameOver:
                        (context, g) => GameOverOverlay(game: g as MyGame),
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
