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

  ImpostorMode? selectedMode;
  ImpostorStep currentStep = ImpostorStep.modeSelection;

  final TextEditingController playersController = TextEditingController(text: '6');
  final TextEditingController impostorsController = TextEditingController(text: '1');
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

  bool currentPlayerIsImpostor() {
    return impostorIndexes.contains(currentPlayerIndex);
  }



  @override
  void dispose() {
    playersController.dispose();
    impostorsController.dispose();
    namesController.dispose();
    super.dispose();
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

    final words = List<String>.from(categoryData['words']);

    selectedCategory = categoryData['category'] as String;
    selectedHint = categoryData['hint'] as String;
    selectedWord = words[_random.nextInt(words.length)];

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);

    playerSecrets = List.generate(playersCount, (index) {
      if (impostorIndexes.contains(index)) return 'IMPOSTOR';
      return selectedWord;
    });
  }

  void setupRolesMode() {
    final scenario =
    rolesScenariosData[_random.nextInt(rolesScenariosData.length)];

    final place = scenario['place'] as String;
    final roles = List<String>.from(scenario['roles']);

    roles.shuffle();

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
    final pair =
    questionPairsData[_random.nextInt(questionPairsData.length)];

    selectedCategory = 'Pregunta';
    selectedWord = pair['normal']!;
    selectedHint = pair['hint']!;

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);

    playerSecrets = List.generate(playersCount, (index) {
      if (impostorIndexes.contains(index)) {
        return pair['impostor']!;
      }

      return pair['normal']!;
    });
  }

  void setupFakeFactMode() {
    final facts = List<Map<String, String>>.from(curiousFactsData)..shuffle(_random);

    impostorIndexes = generateImpostorIndexes(playersCount, impostorsCount);

    selectedCategory = 'Datos curiosos';
    selectedHint = 'Invéntate un dato que suene real';

    int factCursor = 0;

    playerSecrets = List.generate(playersCount, (index) {
      if (impostorIndexes.contains(index)) {
        return 'ERES EL IMPOSTOR\n\nInvéntate un dato curioso falso, pero que parezca real.';
      }

      final fact = facts[factCursor % facts.length];
      factCursor++;

      return fact['fact']!;
    });

    selectedWord = 'Impostor(es): ${impostorIndexes.map((e) => playerNames[e]).join(', ')}';
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

  void showRulesDialog() {
    if (selectedMode == null) return;

    String title = getModeTitle(selectedMode!);
    List<String> rules = [];

    switch (selectedMode!) {
      case ImpostorMode.classic:
        rules = [
          'Todos reciben la misma palabra menos el impostor.',
          'El impostor debe intentar disimular.',
          'Haced preguntas sin decir la palabra exacta.',
          'Después votáis quién creéis que es el impostor.',
        ];
        break;
      case ImpostorMode.roles:
        rules = [
          'Todos comparten el mismo lugar.',
          'Cada jugador normal recibe un rol distinto.',
          'El impostor no sabe ni el sitio ni el rol.',
          'Hay que descubrir quién responde raro.',
        ];
        break;
      case ImpostorMode.question:
        rules = [
          'Todos reciben una pregunta.',
          'Uno o varios reciben una parecida, pero no igual.',
          'Responded con naturalidad.',
          'Detectad quién parece estar contestando a otra cosa.',
        ];
        break;
      case ImpostorMode.fakeFact:
        rules = [
          'Los jugadores normales reciben un dato curioso real.',
          'El impostor no recibe dato y debe inventarse uno.',
          'Cada jugador dice su dato en voz alta.',
          'Después votáis quién creéis que se lo ha inventado.',
        ];
        break;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1B132C),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Normas · $title',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              ...rules.map(
                    (rule) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.star_rounded, color: Colors.pinkAccent, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rule,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.82),
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Cerrar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showCustomSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.pinkAccent,
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

  Widget buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildTopBar({
    required String title,
    String? subtitle,
    bool showBack = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// BOTÓN VOLVER AL MENÚ (ChillScreen)
        Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context); // ← vuelve al menú
            },
            icon: const Icon(
              Icons.home_rounded,
              color: Colors.white,
            ),
            tooltip: 'Volver al menú',
          ),
        ),

        /// BOTÓN BACK INTERNO
        if (showBack)
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: resetGame,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
            ),
          ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFF70A6), Color(0xFFFFB86C)],
                ).createShader(bounds),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),

        /// BOTÓN NORMAS
        if (selectedMode != null)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: IconButton(
              onPressed: showRulesDialog,
              icon: const Icon(
                Icons.question_mark_rounded,
                color: Colors.white,
              ),
              tooltip: 'Normas',
            ),
          ),
      ],
    );
  }

  Widget buildModeCard({
    required String title,
    required String subtitle,
    required String emoji,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1430),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pinkAccent.withOpacity(0.25),
                    Colors.orangeAccent.withOpacity(0.18),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.70),
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
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
        const SizedBox(height: 26),
        buildModeCard(
          title: 'Impostor clásico',
          subtitle: 'Todos reciben una palabra menos el impostor.',
          emoji: '🕵️',
          onTap: () => goToSetup(ImpostorMode.classic),
        ),
        const SizedBox(height: 14),
        buildModeCard(
          title: 'Impostor con roles',
          subtitle: 'Mismo lugar, roles distintos y alguien no sabe nada.',
          emoji: '🎭',
          onTap: () => goToSetup(ImpostorMode.roles),
        ),
        const SizedBox(height: 14),
        buildModeCard(
          title: 'Pregunta distinta',
          subtitle: 'Uno recibe una pregunta parecida, pero no igual.',
          emoji: '❓',
          onTap: () => goToSetup(ImpostorMode.question),
        ),
        const SizedBox(height: 14),
        buildModeCard(
          title: 'Datos curiosos',
          subtitle: 'Todos reciben un dato real menos el impostor, que debe inventárselo.',
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
        const SizedBox(height: 22),
        buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configuración',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Número de jugadores',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: playersController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration('Ejemplo: 6'),
              ),
              if (showImpostorsInput) ...[
                const SizedBox(height: 18),
                const Text(
                  'Número de impostores',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: impostorsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration('Ejemplo: 1'),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'Nombres de jugadores',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: namesController,
                maxLines: 6,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration(
                  'Uno por línea\nAniol\nMartina\nJan',
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF120D20),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: SwitchListTile(
                  value: showHints,
                  onChanged: (value) {
                    setState(() {
                      showHints = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: Colors.pinkAccent,
                  title: const Text(
                    'Activar pista',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Muestra una pequeña ayuda en la revelación',
                    style: TextStyle(color: Colors.white.withOpacity(0.60)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: startGame,
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Empezar partida',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
        const SizedBox(height: 24),
        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.pinkAccent.withOpacity(0.30),
                      Colors.orangeAccent.withOpacity(0.18),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                playerName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Coge el móvil y pulsa para ver tu información secreta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: revealRole,
                  style: mainButtonStyle(),
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Ver mi información',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
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
        const SizedBox(height: 24),
        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF120D20),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Text(
                  secret,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (showHints && selectedHint.isNotEmpty && currentPlayerIsImpostor()) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.orangeAccent.withOpacity(0.18),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_rounded, color: Colors.orangeAccent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pista: $selectedHint',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: hideRole,
                      style: secondaryButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Ocultar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          currentPlayerIndex == playersCount - 1 ? 'Finalizar' : 'Siguiente',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
      'Todos ya conocen su palabra.\n\n'
          'Haced preguntas sin decir la palabra exacta.\n'
          'Después votad quién creéis que es el impostor.';
    } else if (selectedMode == ImpostorMode.roles) {
      summaryText =
      'Todos ya conocen su rol.\n\n'
          'El impostor debe intentar descubrir el lugar.\n'
          'Los demás deben descubrir quién no sabe nada.';
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
          title: '¡Todo listo!',
          subtitle: 'La partida ya puede empezar',
          showBack: true,
        ),
        const SizedBox(height: 24),
        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.greenAccent.withOpacity(0.25),
                      Colors.pinkAccent.withOpacity(0.22),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Ya podéis empezar a jugar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF120D20),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Text(
                  summaryText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: resetGame,
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Volver al inicio',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
      filled: true,
      fillColor: const Color(0xFF120D20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.pinkAccent),
      ),
    );
  }

  ButtonStyle mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.pinkAccent,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: Colors.white.withOpacity(0.18)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
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
      backgroundColor: const Color(0xFF09050F),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF211133),
                Color(0xFF12091E),
                Color(0xFF09050F),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                left: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.pinkAccent.withOpacity(0.10),
                  ),
                ),
              ),
              Positioned(
                top: 100,
                right: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orangeAccent.withOpacity(0.08),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: SingleChildScrollView(
                    child: bodyContent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}