import 'dart:math';
import 'package:flutter/material.dart';
import '../data/impostor_data.dart';
import '../widgets/app_logo_button.dart';
enum ImpostorMode {
  classic,
  roles,
  question,
  fakeFact,
}

enum ImpostorStep {
  modeSelection,
  setup,
  passPhone,
  reveal,
  finished,
}

class ImpostorScreen extends StatefulWidget {
  const ImpostorScreen({super.key});

  @override
  State<ImpostorScreen> createState() => _ImpostorScreenState();
}

class _ImpostorScreenState extends State<ImpostorScreen> {
  final Random _random = Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentPink = Color(0xFFFF4D6D);
  static const Color accentOrange = Color(0xFFFFB86C);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color accentPurple = Color(0xFF8B5CF6);

  ImpostorMode? selectedMode;
  ImpostorStep currentStep = ImpostorStep.modeSelection;

  final TextEditingController playersController =
  TextEditingController(text: '6');
  final TextEditingController impostorsController =
  TextEditingController(text: '1');
  final TextEditingController namesController = TextEditingController();

  int playersCount = 6;
  int impostorsCount = 1;
  int currentPlayerIndex = 0;
  bool showHints = true;

  List<String> playerSecrets = [];
  List<int> impostorIndexes = [];
  List<String> playerNames = [];

  String selectedWord = '';
  String selectedCategory = '';
  String selectedHint = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

    });
  }

  @override
  void dispose() {
    playersController.dispose();
    impostorsController.dispose();
    namesController.dispose();
    super.dispose();
  }

  bool currentPlayerIsImpostor() {
    return impostorIndexes.contains(currentPlayerIndex);
  }

  void resetGame() {
    setState(() {
      selectedMode = null;
      currentStep = ImpostorStep.modeSelection;
      playersCount = 6;
      impostorsCount = 1;
      currentPlayerIndex = 0;
      showHints = true;

      playersController.text = '6';
      impostorsController.text = '1';
      namesController.clear();

      playerSecrets = [];
      impostorIndexes = [];
      playerNames = [];

      selectedWord = '';
      selectedCategory = '';
      selectedHint = '';
    });
  }

  void _goBack() {
    if (currentStep == ImpostorStep.modeSelection) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      selectedMode = null;
      currentStep = ImpostorStep.modeSelection;
      currentPlayerIndex = 0;

      playerSecrets = [];
      impostorIndexes = [];
      playerNames = [];

      selectedWord = '';
      selectedCategory = '';
      selectedHint = '';
    });
  }

  void goToSetup(ImpostorMode mode) {
    setState(() {
      selectedMode = mode;
      currentStep = ImpostorStep.setup;
      currentPlayerIndex = 0;
      playerSecrets = [];
      impostorIndexes = [];
      playerNames = [];
      selectedWord = '';
      selectedCategory = '';
      selectedHint = '';
    });
  }

  void startGame() {
    final parsedPlayers = int.tryParse(playersController.text) ?? 0;
    final parsedImpostors = int.tryParse(impostorsController.text) ?? 0;

    if (parsedPlayers < 3) {
      showCustomSnackBar('Tiene que haber al menos 3 jugadores');
      return;
    }

    if (parsedImpostors < 1) {
      showCustomSnackBar('Tiene que haber al menos 1 impostor');
      return;
    }

    if (parsedImpostors >= parsedPlayers) {
      showCustomSnackBar('No puede haber tantos impostores como jugadores');
      return;
    }

    playersCount = parsedPlayers;
    impostorsCount = parsedImpostors;
    generatePlayerNames();

    switch (selectedMode!) {
      case ImpostorMode.classic:
        setupClassicMode();
        break;
      case ImpostorMode.roles:
        setupRolesMode();
        break;
      case ImpostorMode.question:
        setupQuestionMode();
        break;
      case ImpostorMode.fakeFact:
        setupFakeFactMode();
        break;
    }

    setState(() {
      currentPlayerIndex = 0;
      currentStep = ImpostorStep.passPhone;
    });
  }

  void generatePlayerNames() {
    final rawNames = namesController.text
        .split('\n')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    playerNames = List.generate(playersCount, (index) {
      if (index < rawNames.length) return rawNames[index];
      return 'Jugador ${index + 1}';
    });
  }

  void setupClassicMode() {
    final categoryData =
    classicWordsData[_random.nextInt(classicWordsData.length)];

    final words = (categoryData['words'] as List)
        .map((item) => Map<String, String>.from(item as Map))
        .toList();

    final selectedData = words[_random.nextInt(words.length)];

    selectedCategory = categoryData['category'] as String;
    selectedWord = selectedData['word']!;
    selectedHint = selectedData['hint']!;

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);

    playerSecrets = List.generate(playersCount, (index) {
      return impostorIndexes.contains(index) ? 'IMPOSTOR' : selectedWord;
    });
  }

  void setupRolesMode() {
    final scenario =
    rolesScenariosData[_random.nextInt(rolesScenariosData.length)];

    final place = scenario['place'] as String;
    final roles = List<String>.from(scenario['roles'])..shuffle(_random);

    selectedCategory = 'Lugar';
    selectedWord = place;
    selectedHint = scenario['hint'] as String;

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);

    int roleCursor = 0;
    playerSecrets = List.generate(playersCount, (index) {
      if (impostorIndexes.contains(index)) return 'IMPOSTOR';

      final role = roles[roleCursor % roles.length];
      roleCursor++;
      return '$place|$role';
    });
  }

  void setupQuestionMode() {
    final pair = questionPairsData[_random.nextInt(questionPairsData.length)];

    selectedCategory = 'Pregunta';
    selectedWord = pair['normal']!;
    selectedHint = '';

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);

    playerSecrets = List.generate(playersCount, (index) {
      return impostorIndexes.contains(index)
          ? pair['impostor']!
          : pair['normal']!;
    });
  }

  void setupFakeFactMode() {
    final facts = List<Map<String, String>>.from(curiousFactsData)
      ..shuffle(_random);

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);
    selectedCategory = 'Datos curiosos';
    selectedHint = '';

    int factCursor = 0;
    playerSecrets = List.generate(playersCount, (index) {
      if (impostorIndexes.contains(index)) {
        return 'ERES EL IMPOSTOR\n\nInvéntate un dato curioso falso, pero que parezca real.';
      }

      final fact = facts[factCursor % facts.length];
      factCursor++;
      return fact['fact']!;
    });

    selectedWord =
    'Impostor(es): ${impostorIndexes.map((index) => playerNames[index]).join(', ')}';
  }

  List<int> generateImpostorIndexes(int totalPlayers, int totalImpostors) {
    final Set<int> indexes = {};

    while (indexes.length < totalImpostors) {
      indexes.add(_random.nextInt(totalPlayers));
    }

    return indexes.toList();
  }

  void revealRole() {
    setState(() {
      currentStep = ImpostorStep.reveal;
    });
  }

  void hideRole() {
    setState(() {
      currentStep = ImpostorStep.passPhone;
    });
  }

  void nextPlayer() {
    if (currentPlayerIndex < playersCount - 1) {
      setState(() {
        currentPlayerIndex++;
        currentStep = ImpostorStep.passPhone;
      });
    } else {
      setState(() {
        currentStep = ImpostorStep.finished;
      });
    }
  }

  void showCustomSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: appBlue,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String getModeTitle(ImpostorMode mode) {
    switch (mode) {
      case ImpostorMode.classic:
        return 'Impostor clásico';
      case ImpostorMode.roles:
        return 'Impostor con roles';
      case ImpostorMode.question:
        return 'Pregunta distinta';
      case ImpostorMode.fakeFact:
        return 'Dato falso';
    }
  }

  String getPlayerSecretDisplay() {
    final secret = playerSecrets[currentPlayerIndex];

    if (selectedMode == ImpostorMode.classic) {
      return secret == 'IMPOSTOR' ? 'Eres el impostor' : secret;
    }

    if (selectedMode == ImpostorMode.roles) {
      if (secret == 'IMPOSTOR') return 'Eres el impostor';

      final parts = secret.split('|');
      if (parts.length == 2) {
        return 'Lugar: ${parts[0]}\n\nRol: ${parts[1]}';
      }
    }

    return secret;
  }

  Color get modeColor {
    switch (selectedMode) {
      case ImpostorMode.classic:
        return accentPink;
      case ImpostorMode.roles:
        return accentOrange;
      case ImpostorMode.question:
        return accentGreen;
      case ImpostorMode.fakeFact:
        return accentYellow;
      case null:
        return accentPink;
    }
  }

  IconData get modeIcon {
    switch (selectedMode) {
      case ImpostorMode.classic:
        return Icons.visibility_off_rounded;
      case ImpostorMode.roles:
        return Icons.theater_comedy_rounded;
      case ImpostorMode.question:
        return Icons.quiz_rounded;
      case ImpostorMode.fakeFact:
        return Icons.fact_check_rounded;
      case null:
        return Icons.person_search_rounded;
    }
  }

  ButtonStyle mainButtonStyle({Color? background, Color? foreground}) {
    return ElevatedButton.styleFrom(
      backgroundColor: background ?? appWhite,
      foregroundColor: foreground ?? appBlue,
      disabledBackgroundColor: appWhite.withOpacity(0.18),
      disabledForegroundColor: appWhite.withOpacity(0.42),
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }

  ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: appWhite,
      side: BorderSide(color: appWhite.withOpacity(0.70), width: 2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    );
  }

  Widget circleButton({
    required Widget child,
    required VoidCallback onTap,
    required bool compact,
  }) {
    final size = compact ? 44.0 : 50.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: appWhite.withOpacity(0.85), width: 2.2),
        ),
        child: Center(child: child),
      ),
    );
  }

  String get currentTitle {
    switch (currentStep) {
      case ImpostorStep.modeSelection:
        return 'juego del impostor';
      case ImpostorStep.setup:
        return getModeTitle(selectedMode!).toLowerCase();
      case ImpostorStep.passPhone:
        return 'pasa el móvil';
      case ImpostorStep.reveal:
        return playerNames[currentPlayerIndex].toLowerCase();
      case ImpostorStep.finished:
        return 'todo listo';
    }
  }

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 34.0 : 42.0;
    final titleHeight = compact ? 70.0 : 92.0;
    final lineTop = compact ? 40.0 : 60.0;
    final showReset = currentStep != ImpostorStep.modeSelection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppLogoButton(
              compact: compact,
              onTap: () => Navigator.pop(context),
            ),
            Row(
              children: [
                if (showReset) ...[

                  SizedBox(width: compact ? 9 : 12),
                ],
                circleButton(
                  compact: compact,
                  onTap: showRulesDialog,
                  child: Icon(
                    Icons.question_mark_rounded,
                    color: appWhite,
                    size: compact ? 23 : 27,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: compact ? 14 : 24),
        Padding(
          padding: EdgeInsets.only(
            right: compact ? 18 : 28,
          ),
          child: SizedBox(
            width: double.infinity,
            height: titleHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  bottom: 10,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topRight,
                      child: Text(
                        currentTitle,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: appWhite,
                          fontSize: titleSize,
                          height: 1.9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: lineTop,

                  // Cancela el padding horizontal general de la pantalla
                  // para que la línea empiece en el borde izquierdo.
                  left: compact ? -13 : -18,

                  // Termina antes del borde derecho,
                  // igual que en la pantalla Chill.
                  right: 0,

                  child: Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPanel({
    required Widget child,
    EdgeInsets? padding,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: borderColor ?? appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      child: child,
    );
  }

  Widget buildProgress({required bool compact}) {
    final current = currentPlayerIndex + 1;
    final total = playersCount;
    final progress = total == 0 ? 0.0 : current / total;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'JUGADOR $current DE $total',
              style: TextStyle(
                color: appWhite.withOpacity(0.72),
                fontSize: compact ? 10.5 : 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: appWhite,
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: compact ? 11 : 14,
          decoration: BoxDecoration(
            color: appWhite.withOpacity(0.14),
            border: Border.all(color: appWhite.withOpacity(0.30), width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(modeColor),
          ),
        ),
      ],
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback? onTap,
    required bool compact,
  }) {
    return SizedBox(
      height: compact ? 54 : 62,
      child: Material(
        color: onTap == null
            ? backgroundColor.withOpacity(0.30)
            : backgroundColor,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: appWhite.withOpacity(onTap == null ? 0.12 : 0.28),
                width: 2.1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: foregroundColor.withOpacity(onTap == null ? 0.40 : 1),
                  size: compact ? 24 : 28,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor.withOpacity(
                        onTap == null ? 0.40 : 1,
                      ),
                      fontSize: compact ? 11.5 : 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.35,
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

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: appWhite.withOpacity(0.45),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: appWhite.withOpacity(0.07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: appWhite.withOpacity(0.28), width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: appWhite.withOpacity(0.28), width: 1.4),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: appWhite, width: 2),
      ),
    );
  }

  Widget rulesItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(color: appWhite.withOpacity(0.26), width: 1.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: appWhite, size: 22),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.72),
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showRulesDialog() {
    final generic = selectedMode == null;
    final title = generic ? 'Juego del impostor' : getModeTitle(selectedMode!);
    final List<Map<String, dynamic>> rules = [];

    if (generic) {
      rules.addAll([
        {
          'icon': Icons.videogame_asset_rounded,
          'title': 'Elige modo',
          'text': 'Escoge entre clásico, roles, pregunta distinta o dato falso.',
        },
        {
          'icon': Icons.groups_rounded,
          'title': 'Configura',
          'text': 'Indica jugadores, impostores y nombres antes de empezar.',
        },
        {
          'icon': Icons.phone_android_rounded,
          'title': 'Pasa el móvil',
          'text': 'Cada jugador mira su información en secreto.',
        },
        {
          'icon': Icons.visibility_off_rounded,
          'title': 'Disimula',
          'text': 'El impostor debe evitar que lo descubran durante la conversación.',
        },
        {
          'icon': Icons.how_to_vote_rounded,
          'title': 'Votad',
          'text': 'Al final debatís y votáis quién creéis que es el impostor.',
        },
      ]);
    } else {
      switch (selectedMode!) {
        case ImpostorMode.classic:
          rules.addAll([
            {
              'icon': Icons.text_fields_rounded,
              'title': 'Palabra secreta',
              'text': 'Todos reciben la misma palabra menos el impostor.',
            },
            {
              'icon': Icons.visibility_off_rounded,
              'title': 'Impostor',
              'text': 'El impostor no sabe la palabra y debe disimular.',
            },
            {
              'icon': Icons.question_answer_rounded,
              'title': 'Preguntas',
              'text': 'Haced preguntas sin decir la palabra exacta.',
            },
            {
              'icon': Icons.how_to_vote_rounded,
              'title': 'Votación',
              'text': 'Después votáis quién creéis que es el impostor.',
            },
          ]);
          break;
        case ImpostorMode.roles:
          rules.addAll([
            {
              'icon': Icons.location_on_rounded,
              'title': 'Lugar común',
              'text': 'Todos comparten el mismo lugar.',
            },
            {
              'icon': Icons.theater_comedy_rounded,
              'title': 'Roles',
              'text': 'Cada jugador normal recibe un rol distinto.',
            },
            {
              'icon': Icons.visibility_off_rounded,
              'title': 'Impostor',
              'text': 'El impostor no conoce ni el lugar ni el rol.',
            },
            {
              'icon': Icons.search_rounded,
              'title': 'Detectad',
              'text': 'Descubrid quién responde de forma extraña.',
            },
          ]);
          break;
        case ImpostorMode.question:
          rules.addAll([
            {
              'icon': Icons.quiz_rounded,
              'title': 'Pregunta',
              'text': 'Todos reciben una pregunta.',
            },
            {
              'icon': Icons.compare_arrows_rounded,
              'title': 'Distinta',
              'text': 'Uno o varios reciben una parecida, pero diferente.',
            },
            {
              'icon': Icons.record_voice_over_rounded,
              'title': 'Responded',
              'text': 'Responded con naturalidad sin enseñar la pantalla.',
            },
            {
              'icon': Icons.search_rounded,
              'title': 'Detectad',
              'text': 'Encontrad quién parece estar contestando otra cosa.',
            },
          ]);
          break;
        case ImpostorMode.fakeFact:
          rules.addAll([
            {
              'icon': Icons.fact_check_rounded,
              'title': 'Dato real',
              'text': 'Los jugadores normales reciben un dato curioso real.',
            },
            {
              'icon': Icons.psychology_rounded,
              'title': 'Dato falso',
              'text': 'El impostor inventa uno que parezca verdadero.',
            },
            {
              'icon': Icons.record_voice_over_rounded,
              'title': 'Decidlo',
              'text': 'Cada jugador dice su dato en voz alta.',
            },
            {
              'icon': Icons.how_to_vote_rounded,
              'title': 'Votad',
              'text': 'Después votáis quién creéis que se lo ha inventado.',
            },
          ]);
          break;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(color: appWhite.withOpacity(0.75), width: 2.2),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appWhite.withOpacity(0.85),
                            width: 2.1,
                          ),
                        ),
                        child: const Icon(
                          Icons.question_mark_rounded,
                          color: appWhite,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'normas',
                          style: TextStyle(
                            color: appWhite,
                            fontSize: 38,
                            height: 0.9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(height: 3, color: appWhite.withOpacity(0.58)),
                  const SizedBox(height: 18),
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...rules.map(
                        (rule) => rulesItem(
                      icon: rule['icon'] as IconData,
                      title: rule['title'] as String,
                      text: rule['text'] as String,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'ENTENDIDO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
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
    required bool compact,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 13,
            vertical: compact ? 11 : 15,
          ),
          decoration: BoxDecoration(
            color: appWhite.withOpacity(0.08),
            border: Border(
              left: BorderSide(color: color, width: compact ? 5 : 7),
              bottom: BorderSide(color: appWhite.withOpacity(0.30), width: 2),
              top: BorderSide(color: appWhite.withOpacity(0.18), width: 1),
              right: BorderSide(color: appWhite.withOpacity(0.18), width: 1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 54 : 66,
                height: compact ? 54 : 66,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.75), width: 2),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: compact ? 30 : 38,
                ),
              ),
              SizedBox(height: compact ? 8 : 11),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appWhite,
                  fontSize: compact ? 12 : 14,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.35,
                ),
              ),
              SizedBox(height: compact ? 5 : 7),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: compact ? 3 : 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appWhite.withOpacity(0.68),
                  fontSize: compact ? 10.2 : 11.5,
                  height: 1.22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildModeSelection({required bool compact}) {
    final cards = [
      (
      title: 'Clásico',
      subtitle: 'Todos tienen una palabra menos el impostor.',
      icon: Icons.visibility_off_rounded,
      color: accentPink,
      mode: ImpostorMode.classic,
      ),
      (
      title: 'Con roles',
      subtitle: 'Mismo lugar, roles distintos y alguien no sabe nada.',
      icon: Icons.theater_comedy_rounded,
      color: accentOrange,
      mode: ImpostorMode.roles,
      ),
      (
      title: 'Pregunta distinta',
      subtitle: 'Uno recibe una pregunta parecida, pero diferente.',
      icon: Icons.quiz_rounded,
      color: accentGreen,
      mode: ImpostorMode.question,
      ),
      (
      title: 'Dato falso',
      subtitle: 'Todos tienen un dato real menos el impostor.',
      icon: Icons.fact_check_rounded,
      color: accentYellow,
      mode: ImpostorMode.fakeFact,
      ),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: compact ? 9 : 12,
        mainAxisSpacing: compact ? 9 : 12,
        childAspectRatio: compact ? 0.88 : 0.82,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return buildModeCard(
          title: card.title,
          subtitle: card.subtitle,
          icon: card.icon,
          color: card.color,
          compact: compact,
          onTap: () => goToSetup(card.mode),
        );
      },
    );
  }

  Widget buildSetup({required bool compact}) {
    final mode = selectedMode!;
    final showHintSwitch =
        mode == ImpostorMode.classic || mode == ImpostorMode.roles;

    return SingleChildScrollView(
      child: buildPanel(
        padding: EdgeInsets.all(compact ? 13 : 17),
        borderColor: modeColor.withOpacity(0.65),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: compact ? 50 : 60,
                  height: compact ? 50 : 60,
                  decoration: BoxDecoration(
                    color: modeColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: modeColor, width: 2.2),
                  ),
                  child: Icon(
                    modeIcon,
                    color: modeColor,
                    size: compact ? 28 : 34,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONFIGURACIÓN',
                        style: TextStyle(
                          color: appWhite.withOpacity(0.62),
                          fontSize: compact ? 10.5 : 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getModeTitle(mode),
                        style: TextStyle(
                          color: appWhite,
                          fontSize: compact ? 21 : 25,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 16 : 20),
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    label: 'JUGADORES',
                    controller: playersController,
                    hint: '6',
                    compact: compact,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildNumberInput(
                    label: 'IMPOSTORES',
                    controller: impostorsController,
                    hint: '1',
                    compact: compact,
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 14 : 17),
            Text(
              'NOMBRES DE JUGADORES',
              style: TextStyle(
                color: appWhite.withOpacity(0.70),
                fontSize: compact ? 10.5 : 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namesController,
              minLines: compact ? 3 : 4,
              maxLines: compact ? 4 : 5,
              style: const TextStyle(
                color: appWhite,
                fontWeight: FontWeight.w700,
              ),
              cursorColor: appWhite,
              decoration: inputDecoration(
                'Opcional · uno por línea\nAniol\nMartina\nJan',
              ),
            ),
            if (showHintSwitch) ...[
              SizedBox(height: compact ? 13 : 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.07),
                  border: Border.all(
                    color: appWhite.withOpacity(0.22),
                    width: 1.3,
                  ),
                ),
                child: SwitchListTile(
                  value: showHints,
                  onChanged: (value) => setState(() => showHints = value),
                  contentPadding: EdgeInsets.zero,
                  activeColor: modeColor,
                  title: const Text(
                    'Pista para el impostor',
                    style: TextStyle(
                      color: appWhite,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    'Recibirá una pista corta para poder disimular.',
                    style: TextStyle(
                      color: appWhite.withOpacity(0.60),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: compact ? 14 : 18),
            buildActionButton(
              icon: Icons.play_arrow_rounded,
              label: 'EMPEZAR PARTIDA',
              backgroundColor: modeColor,
              foregroundColor:
              mode == ImpostorMode.fakeFact ? appBlue : appWhite,
              onTap: startGame,
              compact: compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool compact,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: appWhite.withOpacity(0.70),
            fontSize: compact ? 10 : 11.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: appWhite,
            fontSize: compact ? 19 : 22,
            fontWeight: FontWeight.w900,
          ),
          cursorColor: appWhite,
          decoration: inputDecoration(hint),
        ),
      ],
    );
  }

  Widget buildPassPhone({required bool compact}) {
    final playerName = playerNames[currentPlayerIndex];

    return Column(
      children: [
        buildProgress(compact: compact),
        SizedBox(height: compact ? 10 : 14),
        Expanded(
          child: buildPanel(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 18 : 24,
              vertical: compact ? 18 : 28,
            ),
            borderColor: modeColor.withOpacity(0.65),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: compact ? 78 : 96,
                      height: compact ? 78 : 96,
                      decoration: BoxDecoration(
                        color: modeColor.withOpacity(0.14),
                        shape: BoxShape.circle,
                        border: Border.all(color: modeColor, width: 2.6),
                      ),
                      child: Icon(
                        Icons.phone_android_rounded,
                        color: modeColor,
                        size: compact ? 39 : 48,
                      ),
                    ),
                    SizedBox(height: compact ? 18 : 26),
                    Text(
                      'PASA EL MÓVIL A',
                      style: TextStyle(
                        color: appWhite.withOpacity(0.62),
                        fontSize: compact ? 11 : 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 9),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        playerName.toLowerCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appWhite,
                          fontSize: compact ? 38 : 48,
                          height: 0.95,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 16 : 22),
                    Text(
                      'Que nadie más mire la pantalla.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appWhite.withOpacity(0.72),
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        buildActionButton(
          icon: Icons.visibility_rounded,
          label: 'VER MI INFORMACIÓN',
          backgroundColor: modeColor,
          foregroundColor:
          selectedMode == ImpostorMode.fakeFact ? appBlue : appWhite,
          onTap: revealRole,
          compact: compact,
        ),
      ],
    );
  }

  Widget buildReveal({required bool compact}) {
    final secret = getPlayerSecretDisplay();
    final isImpostor = currentPlayerIsImpostor();
    final secretColor = isImpostor ? accentPink : modeColor;

    return Column(
      children: [
        buildProgress(compact: compact),
        SizedBox(height: compact ? 10 : 14),
        Expanded(
          child: buildPanel(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 22,
              vertical: compact ? 16 : 24,
            ),
            borderColor: secretColor.withOpacity(0.75),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: compact ? 74 : 90,
                      height: compact ? 74 : 90,
                      decoration: BoxDecoration(
                        color: secretColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: secretColor, width: 2.5),
                      ),
                      child: Icon(
                        isImpostor ? Icons.visibility_off_rounded : modeIcon,
                        color: secretColor,
                        size: compact ? 38 : 46,
                      ),
                    ),
                    SizedBox(height: compact ? 16 : 22),
                    Text(
                      isImpostor ? 'TU PAPEL' : selectedCategory.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appWhite.withOpacity(0.62),
                        fontSize: compact ? 10.5 : 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 9),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: Text(
                        secret,
                        key: ValueKey(secret),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appWhite,
                          fontSize: compact ? 24 : 30,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (showHints &&
                        selectedHint.isNotEmpty &&
                        isImpostor) ...[
                      SizedBox(height: compact ? 14 : 18),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(compact ? 11 : 14),
                        decoration: BoxDecoration(
                          color: accentOrange.withOpacity(0.13),
                          border: const Border(
                            left: BorderSide(color: accentOrange, width: 6),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_rounded,
                              color: accentOrange,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Pista: $selectedHint',
                                style: TextStyle(
                                  color: appWhite,
                                  fontSize: compact ? 13 : 15,
                                  height: 1.3,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        Row(
          children: [
            Expanded(
              child: buildActionButton(
                icon: Icons.visibility_off_rounded,
                label: 'OCULTAR',
                backgroundColor: appBlue,
                foregroundColor: appWhite,
                onTap: hideRole,
                compact: compact,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildActionButton(
                icon: currentPlayerIndex == playersCount - 1
                    ? Icons.flag_rounded
                    : Icons.arrow_forward_rounded,
                label: currentPlayerIndex == playersCount - 1
                    ? 'FINALIZAR'
                    : 'SIGUIENTE',
                backgroundColor: modeColor,
                foregroundColor:
                selectedMode == ImpostorMode.fakeFact ? appBlue : appWhite,
                onTap: nextPlayer,
                compact: compact,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFinished({required bool compact}) {
    String summaryText;

    switch (selectedMode!) {
      case ImpostorMode.classic:
        summaryText =
        'Todos conocen su palabra. Haced preguntas sin decirla exactamente y votad quién es el impostor.';
        break;
      case ImpostorMode.roles:
        summaryText =
        'Todos conocen su lugar y su rol. El impostor debe disimular y descubrir el lugar.';
        break;
      case ImpostorMode.question:
        summaryText =
        'Las preguntas ya están repartidas. Responded y descubrid quién recibió la pregunta distinta.';
        break;
      case ImpostorMode.fakeFact:
        summaryText =
        'Cada jugador debe decir su dato. Después debatid quién se lo ha inventado.\n\n$selectedWord';
        break;
    }

    return Column(
      children: [
        Expanded(
          child: buildPanel(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 18 : 24,
              vertical: compact ? 18 : 28,
            ),
            borderColor: accentGreen.withOpacity(0.75),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: compact ? 82 : 100,
                      height: compact ? 82 : 100,
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentGreen, width: 2.6),
                      ),
                      child: Icon(
                        Icons.celebration_rounded,
                        color: accentGreen,
                        size: compact ? 42 : 52,
                      ),
                    ),
                    SizedBox(height: compact ? 18 : 24),
                    Text(
                      'EMPEZAD A JUGAR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appWhite,
                        fontSize: compact ? 28 : 36,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    SizedBox(height: compact ? 16 : 20),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(compact ? 13 : 16),
                      decoration: BoxDecoration(
                        color: appWhite.withOpacity(0.07),
                        border: Border.all(
                          color: appWhite.withOpacity(0.25),
                          width: 1.4,
                        ),
                      ),
                      child: Text(
                        summaryText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appWhite.withOpacity(0.84),
                          fontSize: compact ? 14 : 16,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        buildActionButton(
          icon: Icons.replay_rounded,
          label: 'NUEVA PARTIDA',
          backgroundColor: accentGreen,
          foregroundColor: appBlue,
          onTap: resetGame,
          compact: compact,
        ),
      ],
    );
  }

  Widget buildCurrentStep({required bool compact}) {
    switch (currentStep) {
      case ImpostorStep.modeSelection:
        return buildModeSelection(compact: compact);
      case ImpostorStep.setup:
        return buildSetup(compact: compact);
      case ImpostorStep.passPhone:
        return buildPassPhone(compact: compact);
      case ImpostorStep.reveal:
        return buildReveal(compact: compact);
      case ImpostorStep.finished:
        return buildFinished(compact: compact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: currentStep == ImpostorStep.modeSelection,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: appBlue,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 740;
              final horizontalPadding = compact ? 13.0 : 18.0;
              final verticalPadding = compact ? 11.0 : 18.0;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  compact ? 11 : 16,
                ),
                child: Column(
                  children: [
                    buildTopBar(compact: compact),
                    SizedBox(height: compact ? 10 : 14),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: KeyedSubtree(
                          key: ValueKey(currentStep),
                          child: buildCurrentStep(compact: compact),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
