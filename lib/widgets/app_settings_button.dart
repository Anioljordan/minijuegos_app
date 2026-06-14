import '../core/app_settings.dart';

import 'package:flutter/material.dart';
import '../core/app_settings.dart';

class AppSettingsButton extends StatelessWidget {
  final Color blue;
  final Color white;

  const AppSettingsButton({
    super.key,
    required this.blue,
    required this.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppSettingsSheet.show(
        context,
        blue: blue,
        white: white,
      ),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: white.withOpacity(0.85),
            width: 2.2,
          ),
        ),
        child: Icon(
          Icons.settings_rounded,
          color: white,
          size: 30,
        ),
      ),
    );
  }
}

class AppSettingsSheet {
  static Future<void> show(
      BuildContext context, {
        required Color blue,
        required Color white,
      }) async {
    final settings = AppSettings.instance;
    await settings.load();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return AnimatedBuilder(
          animation: settings,
          builder: (context, _) {
            return Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: white.withOpacity(0.45),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings_rounded,
                          color: white,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            settings.t('settings'),
                            style: TextStyle(
                              color: white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Text(
                      settings.t('language'),
                      style: TextStyle(
                        color: white.withOpacity(0.72),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        _languageButton(
                          settings: settings,
                          blue: blue,
                          white: white,
                          label: settings.t('spanish'),
                          value: 'es',
                        ),
                        const SizedBox(width: 8),
                        _languageButton(
                          settings: settings,
                          blue: blue,
                          white: white,
                          label: settings.t('catalan'),
                          value: 'ca',
                        ),
                        const SizedBox(width: 8),
                        _languageButton(
                          settings: settings,
                          blue: blue,
                          white: white,
                          label: settings.t('english'),
                          value: 'en',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _settingsSwitch(
                      settings: settings,
                      white: white,
                      icon: Icons.volume_up_rounded,
                      title: settings.t('sound'),
                      value: settings.soundEnabled,
                      onChanged: settings.setSoundEnabled,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Icon(
                          Icons.graphic_eq_rounded,
                          color: white,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            settings.t('volume'),
                            style: TextStyle(
                              color: white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${(settings.volume * 100).round()}%',
                          style: TextStyle(
                            color: white.withOpacity(0.75),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    Slider(
                      value: settings.volume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      activeColor: white,
                      inactiveColor: white.withOpacity(0.25),
                      onChanged: settings.soundEnabled
                          ? settings.setVolume
                          : null,
                    ),

                    const SizedBox(height: 10),

                    _settingsSwitch(
                      settings: settings,
                      white: white,
                      icon: Icons.vibration_rounded,
                      title: settings.t('vibration'),
                      value: settings.vibrationEnabled,
                      onChanged: settings.setVibrationEnabled,
                    ),

                    const SizedBox(height: 18),

                    _settingsAction(
                      white: white,
                      icon: Icons.delete_outline_rounded,
                      title: settings.t('resetData'),
                      onTap: () async {
                        Navigator.pop(context);
                        await settings.resetSavedGameData(context);
                      },
                    ),

                    const SizedBox(height: 10),

                    _settingsAction(
                      white: white,
                      icon: Icons.info_outline_rounded,
                      title: settings.t('about'),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'MiniGames',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 MiniGames',
                        );
                      },
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _languageButton({
    required AppSettings settings,
    required Color blue,
    required Color white,
    required String label,
    required String value,
  }) {
    final bool selected = settings.language == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => settings.setLanguage(value),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: selected ? white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: white.withOpacity(0.65),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? blue : white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _settingsSwitch({
    required AppSettings settings,
    required Color white,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: white,
          size: 26,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Switch(
          value: value,
          activeColor: white,
          activeTrackColor: white.withOpacity(0.35),
          inactiveThumbColor: white.withOpacity(0.75),
          inactiveTrackColor: white.withOpacity(0.18),
          onChanged: onChanged,
        ),
      ],
    );
  }

  static Widget _settingsAction({
    required Color white,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: white.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: white.withOpacity(0.65),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}