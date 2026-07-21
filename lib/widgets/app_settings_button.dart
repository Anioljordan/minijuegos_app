import '../core/app_settings.dart';

import 'package:flutter/material.dart';

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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              settings.t('settings'),
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                color: white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
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

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final veryNarrow = constraints.maxWidth < 310;

                        final spanishButton = _languageButton(
                          settings: settings,
                          blue: blue,
                          white: white,
                          label: 'Español',
                          value: 'es',
                        );

                        final catalanButton = _languageButton(
                          settings: settings,
                          blue: blue,
                          white: white,
                          label: 'Català',
                          value: 'ca',
                        );

                        final englishButton = _languageButton(
                          settings: settings,
                          blue: blue,
                          white: white,
                          label: 'English',
                          value: 'en',
                        );

                        if (veryNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              spanishButton,
                              const SizedBox(height: 8),
                              catalanButton,
                              const SizedBox(height: 8),
                              englishButton,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: spanishButton),
                            const SizedBox(width: 8),
                            Expanded(child: catalanButton),
                            const SizedBox(width: 8),
                            Expanded(child: englishButton),
                          ],
                        );
                      },
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
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              settings.t('volume'),
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                color: white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
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


                    const SizedBox(height: 10),

                    _settingsAction(
                      white: white,
                      icon: Icons.info_outline_rounded,
                      title: settings.t('about'),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Cubo',
                          applicationVersion: '1.0.5',
                          applicationLegalese: '© 2026 Cubo',
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
    final selected = settings.language == value;

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Material(
        color: selected ? white : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () async {
            if (selected) return;
            await settings.setLanguage(value);
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? white
                    : white.withOpacity(0.65),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[
                  Icon(
                    Icons.check_rounded,
                    color: blue,
                    size: 17,
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color: selected ? blue : white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
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
          child: Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
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