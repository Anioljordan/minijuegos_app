import 'dart:math';
import 'package:flutter/material.dart';
import '../data/impostor_data.dart';

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
  String selectedFakeFactList = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showRulesDialog();
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
      selectedFakeFactList = '';
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
      selectedFakeFactList = '';
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

    if (selectedMode == ImpostorMode.classic) {
      setupClassicMode();
    } else if (selectedMode == ImpostorMode.roles) {
      setupRolesMode();
    } else if (selectedMode == ImpostorMode.question) {
      setupQuestionMode();
    } else if (selectedMode == ImpostorMode.fakeFact) {
      setupFakeFactMode();
    }

    setState(() {
      currentPlayerIndex = 0;
      currentStep = ImpostorStep.passPhone;
    });
  }

  void generatePlayerNames() {
    final rawNames = namesController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    playerNames = List.generate(playersCount, (index) {
      if (index < rawNames.length) {
        return rawNames[index];
      }
      return 'Jugador ${index + 1}';
    });
  }

  void setupClassicMode() {
    final categoryData =
    classicWordsData[_random.nextInt(classicWordsData.length)];

    final words = (categoryData['words'] as List)
        .map(
          (item) => Map<String, String>.from(item as Map),
    )
        .toList();

    final selectedData =
    words[_random.nextInt(words.length)];

    selectedCategory = categoryData['category'] as String;
    selectedWord = selectedData['word']!;
    selectedHint = selectedData['hint']!;

    impostorIndexes =
        generateImpostorIndexes(playersCount, impostorsCount);

    playerSecrets = List.generate(playersCount, (index) {
      if (impostorIndexes.contains(index)) {
        return 'IMPOSTOR';
      }

      return selectedWord;
    });
  }

  void setupRolesMode() {
    final scenario =
    rolesScenariosData[
    _random.nextInt(rolesScenariosData.length)
    ];

    final place = scenario['place'] as String;
    final roles = List<String>.from(scenario['roles']);

    roles.shuffle(_random);

    selectedCategory = 'Lugar';
    selectedWord = place;
    selectedHint = scenario['hint'] as String;

    impostorIndexes =
        generateImpostorIndexes(playersCount, impostorsCount);

    int roleCursor = 0;

    playerSecrets = List.generate(playersCount, (index) {
      if (impostorIndexes.contains(index)) {
        return 'IMPOSTOR';
      }

      final role = roles[roleCursor % roles.length];
      roleCursor++;

      return '$place|$role';
    });
  }

  void setupQuestionMode() {
    final pair =
    questionPairsData[
    _random.nextInt(questionPairsData.length)
    ];

    selectedCategory = 'Pregunta';
    selectedWord = pair['normal']!;
    // selectedHint = pair['hint']!;

    impostorIndexes =
        generateImpostorIndexes(playersCount, impostorsCount);

    playerSecrets = List.generate(playersCount, (index) {
      if (impostorIndexes.contains(index)) {
        return pair['impostor']!;
      }

      return pair['normal']!;
    });
  }

  void setupFakeFactMode() {
    final facts =
    List<Map<String, String>>.from(curiousFactsData)
      ..shuffle(_random);

    impostorIndexes =
        generateImpostorIndexes(playersCount, impostorsCount);

    selectedCategory = 'Datos curiosos';

    final List<Map<String, String>> factsAsignados = [];

    int factCursor = 0;

    playerSecrets = List.generate(playersCount, (index) {
      if (impostorIndexes.contains(index)) {
        return 'ERES EL IMPOSTOR\n\n'
            'Invéntate un dato curioso falso, '
            'pero que parezca real.';
      }

      final fact = facts[factCursor % facts.length];
      factCursor++;

      factsAsignados.add(fact);

      return fact['fact']!;
    });

    if (factsAsignados.isNotEmpty) {
      final factParaPista =
      factsAsignados[
      _random.nextInt(factsAsignados.length)
      ];

      // selectedHint = factParaPista['hint']!;
    } else {
      selectedHint = '';
    }

    selectedWord =
    'Impostor(es): '
        '${impostorIndexes.map((e) => playerNames[e]).join(', ')}';
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
    ScaffoldMessenger.of(context).showSnackBar(
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
      if (secret == 'IMPOSTOR') return 'Eres el impostor';
      return secret;
    }

    if (selectedMode == ImpostorMode.roles) {
      if (secret == 'IMPOSTOR') return 'Eres el impostor';

      final parts = secret.split('|');
      if (parts.length == 2) {
        return 'Lugar: ${parts[0]}\nRol: ${parts[1]}';
      }
      return secret;
    }

    return secret;
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

  ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: appWhite,
      side: BorderSide(
        color: appWhite.withOpacity(0.70),
        width: 2,
      ),
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
        child: Center(child: child),
      ),
    );
  }

  Widget buildGlassCard({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      child: child,
    );
  }

  Widget buildTopBar({
    required String title,
    String? subtitle,
    bool showBack = false,
  }) {
    String visualTitle = title.toLowerCase();

    if (visualTitle == 'juego del impostor') {
      visualTitle = 'juego del\nimpostor';
    }

    if (visualTitle.length > 18 && !visualTitle.contains('\n')) {
      visualTitle = visualTitle.replaceFirst(' ', '\n');
    }

    final bool multiline = visualTitle.contains('\n');
    final double titleHeight = multiline ? 92 : 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            circleButton(
              onTap: () => Navigator.pop(context),
              child: const Text(
                '8',
                style: TextStyle(
                  color: appWhite,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Row(
              children: [
                if (showBack) ...[
                  circleButton(
                    onTap: resetGame,
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: appWhite,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                circleButton(
                  onTap: showRulesDialog,
                  child: const Icon(
                    Icons.question_mark_rounded,
                    color: appWhite,
                    size: 27,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: SizedBox(
            height: titleHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Text(
                    visualTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 40,
                      height: 0.88,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Positioned(
                  top: titleHeight - 10,
                  left: 0,
                  right: -18,
                  child: Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (subtitle != null) ...[
          const SizedBox(height: 10),
          buildInfoBar(
            text: subtitle,
            color: accentPink,
          ),
        ],
      ],
    );
  }

  Widget buildInfoBar({
    required String text,
    Color color = accentPink,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.06),
        border: Border(
          left: BorderSide(
            color: color,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.36),
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: appWhite.withOpacity(0.76),
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      text.toLowerCase(),
      style: const TextStyle(
        color: appWhite,
        fontSize: 30,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
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
        borderSide: BorderSide(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: appWhite,
          width: 2,
        ),
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
        border: Border.all(
          color: appWhite.withOpacity(0.26),
          width: 1.4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: appWhite,
            size: 22,
          ),
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
    final bool generic = selectedMode == null;
    final String title = generic ? 'Juego del impostor' : getModeTitle(selectedMode!);

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
          'text': 'Pon jugadores, impostores y nombres antes de empezar.',
        },
        {
          'icon': Icons.phone_android_rounded,
          'title': 'Pasa el móvil',
          'text': 'Cada jugador mira su información en secreto.',
        },
        {
          'icon': Icons.visibility_off_rounded,
          'title': 'Disimula',
          'text': 'El impostor debe intentar no ser descubierto durante la conversación.',
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
              'text': 'El impostor no sabe la palabra y debe intentar disimular.',
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
              'text': 'El impostor no sabe ni el sitio ni el rol.',
            },
            {
              'icon': Icons.search_rounded,
              'title': 'Detectad',
              'text': 'Hay que descubrir quién responde raro.',
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
              'text': 'Uno o varios reciben una parecida, pero no igual.',
            },
            {
              'icon': Icons.record_voice_over_rounded,
              'title': 'Responded',
              'text': 'Responded con naturalidad.',
            },
            {
              'icon': Icons.search_rounded,
              'title': 'Detectad',
              'text': 'Encontrad quién parece estar contestando a otra cosa.',
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
              'text': 'El impostor debe inventarse uno que parezca real.',
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
            border: Border.all(
              color: appWhite.withOpacity(0.75),
              width: 2.2,
            ),
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

                  Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),

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
    required String emoji,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appWhite.withOpacity(0.08),
          border: Border(
            left: const BorderSide(
              color: accentPink,
              width: 6,
            ),
            bottom: BorderSide(
              color: appWhite.withOpacity(0.30),
              width: 2,
            ),
            top: BorderSide(
              color: appWhite.withOpacity(0.18),
              width: 1,
            ),
            right: BorderSide(
              color: appWhite.withOpacity(0.18),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 34),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: appWhite.withOpacity(0.68),
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: appWhite.withOpacity(0.75),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: 'Juego del Impostor',
          subtitle: 'Elige el modo y empieza la partida',
        ),

        const SizedBox(height: 18),

        buildModeCard(
          title: 'Impostor clásico',
          subtitle: 'Todos reciben una palabra menos el impostor.',
          emoji: '🕵️',
          onTap: () => goToSetup(ImpostorMode.classic),
        ),

        const SizedBox(height: 12),

        buildModeCard(
          title: 'Impostor con roles',
          subtitle: 'Mismo lugar, roles distintos y alguien no sabe nada.',
          emoji: '🎭',
          onTap: () => goToSetup(ImpostorMode.roles),
        ),

        const SizedBox(height: 12),

        buildModeCard(
          title: 'Pregunta distinta',
          subtitle: 'Uno recibe una pregunta parecida, pero no igual.',
          emoji: '❓',
          onTap: () => goToSetup(ImpostorMode.question),
        ),

        const SizedBox(height: 12),

        buildModeCard(
          title: 'Datos curiosos',
          subtitle: 'Todos reciben un dato real menos el impostor.',
          emoji: '📚',
          onTap: () => goToSetup(ImpostorMode.fakeFact),
        ),
      ],
    );
  }

  Widget buildSetup() {
    final mode = selectedMode!;
    final showImpostorsInput = mode != ImpostorMode.fakeFact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: getModeTitle(mode),
          subtitle: 'Configura la partida',
          showBack: true,
        ),

        const SizedBox(height: 18),

        buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle('Configuración'),

              const SizedBox(height: 16),

              Text(
                'NÚMERO DE JUGADORES',
                style: TextStyle(
                  color: appWhite.withOpacity(0.70),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: playersController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: appWhite,
                decoration: inputDecoration('Ejemplo: 6'),
              ),

              if (showImpostorsInput) ...[
                const SizedBox(height: 16),

                Text(
                  'NÚMERO DE IMPOSTORES',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.70),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: impostorsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: appWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: appWhite,
                  decoration: inputDecoration('Ejemplo: 1'),
                ),
              ],

              const SizedBox(height: 16),

              Text(
                'NOMBRES DE JUGADORES',
                style: TextStyle(
                  color: appWhite.withOpacity(0.70),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: namesController,
                maxLines: 6,
                style: const TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: appWhite,
                decoration: inputDecoration(
                  'Uno por línea\nAniol\nMartina\nJan',
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.07),
                  border: Border.all(
                    color: appWhite.withOpacity(0.22),
                    width: 1.3,
                  ),
                ),
                child: SwitchListTile(
                  value: showHints,
                  onChanged: (value) {
                    setState(() {
                      showHints = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: appWhite,
                  title: const Text(
                    'Activar pista',
                    style: TextStyle(
                      color: appWhite,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    'El impostor recibe una pista de una sola palabra',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.60),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: startGame,
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'EMPEZAR PARTIDA',
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
      ],
    );
  }

  Widget buildPassPhone() {
    final playerName = playerNames[currentPlayerIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: 'Pasa el móvil',
          subtitle: 'Que nadie más mire la pantalla',
          showBack: true,
        ),

        const SizedBox(height: 18),

        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appWhite.withOpacity(0.85),
                    width: 2.2,
                  ),
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  color: appWhite,
                  size: 39,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                playerName.toLowerCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: appWhite,
                  fontSize: 38,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Coge el móvil y pulsa para ver tu información secreta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite.withOpacity(0.72),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: revealRole,
                  style: mainButtonStyle(),
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'VER MI INFORMACIÓN',
                      style: TextStyle(
                        fontSize: 15,
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
      ],
    );
  }

  Widget buildReveal() {
    final secret = getPlayerSecretDisplay();
    final playerName = playerNames[currentPlayerIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: playerName,
          subtitle: 'Lee esto en secreto',
          showBack: true,
        ),

        const SizedBox(height: 18),

        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.08),
                  border: Border.all(
                    color: appWhite.withOpacity(0.28),
                    width: 1.4,
                  ),
                ),
                child: Text(
                  secret,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 25,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),

              if (showHints &&
                  selectedHint.isNotEmpty &&
                  currentPlayerIsImpostor()) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: appWhite.withOpacity(0.08),
                    border: Border(
                      left: const BorderSide(
                        color: accentOrange,
                        width: 6,
                      ),
                      bottom: BorderSide(
                        color: appWhite.withOpacity(0.28),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_rounded,
                        color: appWhite,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pista: $selectedHint',
                          style: const TextStyle(
                            color: appWhite,
                            fontSize: 14,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: hideRole,
                      style: secondaryButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          'OCULTAR',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: nextPlayer,
                      style: mainButtonStyle(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          currentPlayerIndex == playersCount - 1
                              ? 'FINALIZAR'
                              : 'SIGUIENTE',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFinished() {
    String summaryText = '';

    if (selectedMode == ImpostorMode.classic) {
      summaryText =
      'Todos ya conocen su palabra.\n\nHaced preguntas sin decir la palabra exacta.\nDespués votad quién creéis que es el impostor.';
    } else if (selectedMode == ImpostorMode.roles) {
      summaryText =
      'Todos ya conocen su rol.\n\nEl impostor debe intentar descubrir el lugar.\nLos demás deben descubrir quién no sabe nada.';
    } else if (selectedMode == ImpostorMode.question) {
      summaryText =
      'Las preguntas ya están repartidas.\nAhora debatid y descubrid quién tiene la distinta.';
    } else if (selectedMode == ImpostorMode.fakeFact) {
      summaryText =
      'Cada jugador ha dicho su dato.\nAhora debatid quién se lo ha inventado.\n\n$selectedWord';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: 'Todo listo',
          subtitle: 'La partida ya puede empezar',
          showBack: true,
        ),

        const SizedBox(height: 18),

        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appWhite.withOpacity(0.85),
                    width: 2.2,
                  ),
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: appWhite,
                  size: 39,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'empezad\na jugar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite,
                  fontSize: 38,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.08),
                  border: Border.all(
                    color: appWhite.withOpacity(0.28),
                    width: 1.4,
                  ),
                ),
                child: Text(
                  summaryText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 16,
                    height: 1.42,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: resetGame,
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'VOLVER AL INICIO',
                      style: TextStyle(
                        fontSize: 15,
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    switch (currentStep) {
      case ImpostorStep.modeSelection:
        bodyContent = buildModeSelection();
        break;
      case ImpostorStep.setup:
        bodyContent = buildSetup();
        break;
      case ImpostorStep.passPhone:
        bodyContent = buildPassPhone();
        break;
      case ImpostorStep.reveal:
        bodyContent = buildReveal();
        break;
      case ImpostorStep.finished:
        bodyContent = buildFinished();
        break;
    }

    return Scaffold(
      backgroundColor: appBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: SingleChildScrollView(
            child: bodyContent,
          ),
        ),
      ),
    );
  }
}