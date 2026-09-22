import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'yo_nunca_screen.dart';
import '../widgets/app_logo_button.dart';

class YoNuncaModesScreen extends StatelessWidget {
  const YoNuncaModesScreen({super.key});

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);

  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentOrange = Color(0xFFFFB86C);
  static const Color accentPurple = Color(0xFF8B5CF6);

  void abrirModo(
      BuildContext context,
      String modo,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoNuncaScreen(
          modo: modo,
        ),
      ),
    );
  }

  ButtonStyle mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: appWhite,
      foregroundColor: appBlue,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  Widget circleButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: appWhite.withOpacity(0.85),
            width: 2.2,
          ),
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }

  Widget buildTopBar(
      BuildContext context,
      ) {
    final compact =
        MediaQuery.of(context).size.height < 740;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            AppLogoButton(
              compact: compact,
              onTap: () =>
                  Navigator.pop(context),
            ),
            circleButton(
              onTap: () =>
                  mostrarNormas(context),
              child: const Icon(
                Icons.question_mark_rounded,
                color: appWhite,
                size: 27,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Padding(
          padding:
          const EdgeInsets.only(left: 28),
          child: SizedBox(
            height: 94,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment:
                    Alignment.centerLeft,
                    child: Text(
                      'yo nunca',
                      maxLines: 1,
                      style: TextStyle(
                        color: appWhite,
                        fontSize: 42,
                        height: 2.20,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 82,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    color:
                    appWhite.withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget rulesItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.26),
          width: 1.4,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: appWhite,
            size: 22,
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment:
                  Alignment.centerLeft,
                  child: Text(
                    tr(title).toUpperCase(),
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 13.5,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  text,
                  style: TextStyle(
                    color:
                    appWhite.withOpacity(0.72),
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void mostrarNormas(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor:
      Colors.black.withOpacity(0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
        const EdgeInsets.symmetric(
          horizontal: 22,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            18,
          ),
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(
              color:
              appWhite.withOpacity(0.75),
              width: 2.2,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
              MediaQuery.of(context)
                  .size
                  .height *
                  0.78,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration:
                        BoxDecoration(
                          shape:
                          BoxShape.circle,
                          border:
                          Border.all(
                            color: appWhite
                                .withOpacity(
                                0.85),
                            width: 2.1,
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .question_mark_rounded,
                          color: appWhite,
                          size: 28,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      const Expanded(
                        child: Text(
                          'normas',
                          style: TextStyle(
                            color: appWhite,
                            fontSize: 38,
                            height: 0.9,
                            fontWeight:
                            FontWeight.w900,
                            letterSpacing:
                            -0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    height: 3,
                    color:
                    appWhite.withOpacity(
                      0.58,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'YO NUNCA',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  rulesItem(
                    icon: Icons
                        .record_voice_over_rounded,
                    title: 'Yo Nunca',
                    text:
                    'El modo clásico. Aparece una frase de “Yo nunca...” y cada persona responde según si lo ha hecho o no.',
                  ),

                  rulesItem(
                    icon:
                    Icons.groups_rounded,
                    title: 'Por equipos',
                    text:
                    'Una variante de Yo Nunca en la que los jugadores se dividen en equipos y compiten durante la partida.',
                  ),

                  rulesItem(
                    icon: Icons
                        .visibility_off_rounded,
                    title: 'Lobo',
                    text:
                    'Una variante con identidades ocultas en la que tendrás que descubrir quién está jugando como lobo.',
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(
                              context),
                      style:
                      mainButtonStyle(),
                      child: const Padding(
                        padding:
                        EdgeInsets
                            .symmetric(
                          vertical: 14,
                        ),
                        child: Text(
                          'ENTENDIDO',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w900,
                            letterSpacing:
                            0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final compact =
            constraints.maxHeight < 170;

        final iconBoxSize =
        compact ? 58.0 : 82.0;

        final iconSize =
        compact ? 34.0 : 50.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding:
              EdgeInsets.symmetric(
                horizontal:
                compact ? 12 : 18,
                vertical:
                compact ? 8 : 14,
              ),
              decoration: BoxDecoration(
                color:
                appWhite.withOpacity(0.08),
                border: Border(
                  left: BorderSide(
                    color: color,
                    width: 7,
                  ),
                  bottom: BorderSide(
                    color: appWhite
                        .withOpacity(0.30),
                    width: 2,
                  ),
                  top: BorderSide(
                    color: appWhite
                        .withOpacity(0.18),
                  ),
                  right: BorderSide(
                    color: appWhite
                        .withOpacity(0.18),
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Container(
                    width: iconBoxSize,
                    height: iconBoxSize,
                    decoration:
                    BoxDecoration(
                      color: color
                          .withOpacity(0.14),
                      shape:
                      BoxShape.circle,
                      border: Border.all(
                        color: color
                            .withOpacity(
                            0.55),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: iconSize,
                    ),
                  ),

                  SizedBox(
                    height:
                    compact ? 7 : 11,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    child: FittedBox(
                      fit:
                      BoxFit.scaleDown,
                      child: Text(
                        tr(title)
                            .toUpperCase(),
                        maxLines: 1,
                        softWrap: false,
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          color: appWhite,
                          fontSize: compact
                              ? 16
                              : 20,
                          fontWeight:
                          FontWeight
                              .w900,
                          letterSpacing:
                          0.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height:
                    compact ? 3 : 6,
                  ),

                  Text(
                    subtitle,
                    textAlign:
                    TextAlign.center,
                    maxLines: 2,
                    overflow:
                    TextOverflow
                        .ellipsis,
                    style: TextStyle(
                      color: appWhite
                          .withOpacity(0.72),
                      fontSize:
                      compact ? 11 : 13,
                      height: 1.2,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor: appBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final narrow =
                constraints.maxWidth < 380;

            final veryNarrow =
                constraints.maxWidth < 340;

            final availableForCards =
                constraints.maxHeight - 220;

            final cardHeight =
            ((availableForCards - 24) / 3)
                .clamp(
              142.0,
              210.0,
            );

            final horizontalPadding =
            veryNarrow
                ? 8.0
                : narrow
                ? 12.0
                : 18.0;

            return SingleChildScrollView(
              padding:
              EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                16,
              ),
              child: ConstrainedBox(
                constraints:
                BoxConstraints(
                  minHeight:
                  constraints.maxHeight -
                      34,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    buildTopBar(context),

                    const SizedBox(
                      height: 18,
                    ),

                    SizedBox(
                      height: cardHeight,
                      child: buildModeCard(
                        title: 'Yo Nunca',
                        subtitle:
                        'El clásico. Lee la frase y responde si alguna vez lo has hecho.',
                        icon: Icons
                            .chat_bubble_outline_rounded,
                        color: accentGreen,
                        onTap: () =>
                            abrirModo(
                              context,
                              'normal',
                            ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    SizedBox(
                      height: cardHeight,
                      child: buildModeCard(
                        title:
                        'Yo Nunca por equipos',
                        subtitle:
                        'Forma equipos y competid durante las rondas.',
                        icon: Icons
                            .groups_rounded,
                        color:
                        accentOrange,
                        onTap: () =>
                            abrirModo(
                              context,
                              'equipos',
                            ),
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    SizedBox(
                      height: cardHeight,
                      child: buildModeCard(
                        title:
                        'Yo Nunca Lobo',
                        subtitle:
                        'Un modo con identidades ocultas y sospechas.',
                        icon: Icons
                            .visibility_off_rounded,
                        color:
                        accentPurple,
                        onTap: () =>
                            abrirModo(
                              context,
                              'lobo',
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}