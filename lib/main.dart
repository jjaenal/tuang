import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/my_game.dart';
import 'ui/main_menu.dart';
import 'ui/game_over.dart';
import 'ui/hud_overlay.dart';
import 'ui/pause_overlay.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state/app_settings_cubit.dart';
import 'services/ad_service.dart';
import 'services/audio_service.dart';
import 'services/haptics_service.dart';
import 'ui/reward_confirm_overlay.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AudioService.I.init(); // inisialisasi BGM channel
  final MyGame game = MyGame();
  runApp(MyApp(game: game));
}

class MyApp extends StatefulWidget {
  final MyGame game;
  final bool showMainMenuOnBoot;
  const MyApp({super.key, required this.game, this.showMainMenuOnBoot = true});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GameWidget _gameWidget;

  @override
  void initState() {
    super.initState();
    _gameWidget = GameWidget(
      game: widget.game,
      overlayBuilderMap: {
        MyGame.overlayMainMenu:
            (context, g) => MainMenuOverlay(game: g as MyGame),
        MyGame.overlayHud:
            (context, g) => HudOverlay(game: g as MyGame),
        MyGame.overlayPause:
            (context, g) => PauseOverlay(game: g as MyGame),
        MyGame.overlayGameOver:
            (context, g) => GameOverOverlay(game: g as MyGame),
        MyGame.overlayRewardConfirm:
            (context, g) => RewardConfirmOverlay(game: g as MyGame),
      },
      initialActiveOverlays: widget.showMainMenuOnBoot
          ? const [MyGame.overlayMainMenu]
          : const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppSettingsCubit>(
          create: (_) => AppSettingsCubit()..load(),
        ), // load state tersimpan dari SharedPreferences
      ],
      child: BlocListener<AppSettingsCubit, AppSettingsState>(
        listenWhen: (prev, curr) =>
            prev.paused != curr.paused ||
            prev.adsEnabled != curr.adsEnabled ||
            prev.consentGiven != curr.consentGiven ||
            prev.audioOn != curr.audioOn ||
            prev.npaEnabled != curr.npaEnabled ||
            prev.hapticsOn != curr.hapticsOn,
        listener: (context, state) {
          if (state.paused) {
            widget.game.pauseEngine();
            widget.game.overlays.add(MyGame.overlayPause);
          } else {
            widget.game.resumeEngine();
            widget.game.overlays.remove(MyGame.overlayPause);
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
        child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
          builder: (context, app) {
            return MaterialApp(
              locale: null,
              onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('id')],
              theme: ThemeData.dark(),
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    final delta = details.delta;
                    final dir = Vector2(delta.dx, delta.dy);
                    if (dir.length2 > 0) {
                      dir.normalize();
                      widget.game.inputDir = dir;
                    }
                  },
                  onPanEnd: (_) => widget.game.inputDir = Vector2.zero(),
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
                      widget.game.inputDir = dir;
                    },
                    child: _gameWidget,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
