part of 'barcelonamedianoche_screen.dart';

/// Popups de Barcelona Medianoche: normas, invitación, listas de la
/// misión, asesinato, detención, tratos y subasta.
extension _BmDialogs on _BarcelonaMedianocheScreenState {
  Widget _rulesItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return CuboRulesItem(icon: icon, title: title, text: text);
  }

  Future<void> _showRulesDialog() {
    return showCuboDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CuboDialogHeader(),
                  const SizedBox(height: 18),
                  Text('BARCELONA, MEDIANOCHE', style: CuboText.chip(size: 13)),
                  const SizedBox(height: 12),
                  Text(
                    'Una subasta privada, una fortuna familiar y varios invitados dispuestos a ensuciarse las manos. Todos empiezan con 100€ y solo los supervivientes pueden quedarse con la herencia.',
                    style: TextStyle(
                      color: _appWhite.withOpacity(0.78),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _rulesItem(
                    icon: Icons.visibility_off_rounded,
                    title: 'Identidades secretas',
                    text:
                        'Cada jugador es Asesino, Agente o Invitado. Nadie debe enseñar su identidad.',
                  ),
                  _rulesItem(
                    icon: Icons.tune_rounded,
                    title: 'Escenario personalizado',
                    text:
                        'Antes de empezar podéis editar las habitaciones y los objetos del crimen. Escribe una opción por línea.',
                  ),
                  _rulesItem(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Misión del asesino',
                    text:
                        'Cada asesino recibe un objetivo, una habitación y un objeto. Para matar deben cumplirse las tres condiciones.',
                  ),
                  _rulesItem(
                    icon: Icons.groups_rounded,
                    title: 'Sin testigos',
                    text:
                        'No se puede asesinar si hay otro jugador vivo presente. Cuando una misión se cumple, el asesino recibe una nueva.',
                  ),
                  _rulesItem(
                    icon: Icons.payments_rounded,
                    title: 'Cuando alguien muere',
                    text:
                        'La víctima entrega todo su dinero al atacante. Queda eliminada: puede hablar y negociar, pero ya no actúa, puja ni puede ganar.',
                  ),
                  _rulesItem(
                    icon: Icons.local_police_rounded,
                    title: 'Agentes',
                    text:
                        'Un agente puede declarar una detención si ha presenciado el crimen o tiene una prueba clara.',
                  ),
                  _rulesItem(
                    icon: Icons.timer_rounded,
                    title: 'Detención correcta',
                    text:
                        'El asesino paga hasta 40€ al agente y no puede cometer asesinatos durante 10 minutos. Sí puede hablar, negociar y pujar.',
                  ),
                  _rulesItem(
                    icon: Icons.warning_amber_rounded,
                    title: 'Acusación falsa',
                    text:
                        'Si no había prueba clara o el acusado era inocente, el agente paga hasta 40€ al acusado.',
                  ),
                  _rulesItem(
                    icon: Icons.handshake_rounded,
                    title: 'Tratos y robos',
                    text:
                        'Se permiten alianzas, intercambios y robos acordados por la mesa. Registra en la app cualquier cambio de dinero o bienes.',
                  ),
                  _rulesItem(
                    icon: Icons.diamond_rounded,
                    title: 'Subasta final',
                    text:
                        'Al terminar la noche se subastan 5 lotes. Las pujas son secretas y solo participan los jugadores vivos.',
                  ),
                  _rulesItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Quién gana',
                    text:
                        'Gana el superviviente con mayor fortuna total: dinero restante + valor de los bienes adquiridos.',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: CuboButtons.primary(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
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

  Future<void> _showInvitationDialog() {
    return showCuboDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.62),
      builder: (dialogContext) => CuboDialogFrame(
        icon: Icons.mail_outline_rounded,
        title: 'la invitación',
        children: [
          const CuboDialogNote(
            'Habéis sido convocados a una subasta privada. Algunos han venido por dinero. Otros por venganza. Y entre vosotros hay asesinos y agentes encubiertos.',
          ),
          CuboDialogButton(
            label: 'ACEPTAR INVITACIÓN',
            onTap: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }

  Future<void> _showMissionListDialog({required bool editingRooms}) async {
    final title = editingRooms ? 'mis lugares' : 'mis armas';
    final label = editingRooms ? 'LUGARES DISPONIBLES' : 'OBJETOS DEL CRIMEN';
    final hint = editingRooms
        ? 'Biblioteca\nSalón\nJardín\nBodega'
        : 'Copa\nAbrecartas\nCandelabro\nBufanda';
    final defaults = editingRooms
        ? BarcelonaMedianocheGame.defaultRooms
        : BarcelonaMedianocheGame.defaultWeapons;
    final sourceController = editingRooms ? roomsController : weaponsController;
    final editorController = TextEditingController(text: sourceController.text);

    void save(BuildContext dialogContext) {
      final cleaned = editorController.text
          .split('\n')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      if (cleaned.isEmpty) {
        _snack(
          editingRooms
              ? 'Añade al menos un lugar.'
              : 'Añade al menos un objeto del crimen.',
        );
        return;
      }

      _update(() {
        sourceController.text = cleaned.join('\n');
        game.setMissionOptions(
          roomNames: roomsController.text.split('\n'),
          weaponNames: weaponsController.text.split('\n'),
        );
      });

      Navigator.pop(dialogContext);
      _snack(editingRooms ? 'Lugares guardados.' : 'Armas guardadas.');
    }

    await showCuboDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.58),
      builder: (dialogContext) => CuboDialogFrame(
        icon: editingRooms ? Icons.place_rounded : Icons.hardware_rounded,
        title: title,
        children: [
          const CuboDialogNote(
            'Escribe una opción por línea. Estas opciones se usarán en las misiones de los asesinos.',
          ),
          CuboDialogLabel(label),
          TextField(
            controller: editorController,
            minLines: 6,
            maxLines: 12,
            style: const TextStyle(
              color: _appWhite,
              fontWeight: FontWeight.w700,
            ),
            cursorColor: _appWhite,
            decoration: _setupInputDecoration(hint),
          ),
          const SizedBox(height: 6),
          CuboDialogButton(
            label: 'RESTAURAR ORIGINALES',
            primary: false,
            onTap: () => editorController.text = defaults.join('\n'),
          ),
          CuboDialogButton(label: 'GUARDAR', onTap: () => save(dialogContext)),
          CuboDialogButton(
            label: 'CANCELAR',
            primary: false,
            onTap: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );

    editorController.dispose();
  }

  Future<void> _showKillDialog() async {
    final alive = game.alivePlayers;

    if (alive.length < 2) {
      _snack('No quedan suficientes jugadores vivos.');
      return;
    }

    String actorId = alive.first.id;
    bool missionVisible = false;
    bool correctRoom = false;
    bool weaponPresent = false;
    bool noWitnesses = false;

    await showCuboDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final actor = game.findPlayerById(actorId)!;
            final target = game.findPlayerById(actor.currentTargetId);
            final canKill =
                missionVisible &&
                actor.role == BmRole.asesino &&
                target != null;

            void confirmKill() {
              final message = game.killTarget(
                killerId: actor.id,
                victimId: target!.id,
                correctRoom: correctRoom,
                weaponPresent: weaponPresent,
                noLivingWitnesses: noWitnesses,
              );

              if (!message.contains('ha sido eliminado')) {
                _snack(message);
                return;
              }

              Navigator.pop(dialogContext);
              _update(() {});
              _snack(message);
            }

            return CuboDialogFrame(
              icon: Icons.local_fire_department_rounded,
              title: 'asesinato',
              children: [
                CuboDialogChoices<String>(
                  label: 'JUGADOR QUE ACTÚA',
                  value: actorId,
                  options: _playerChoices(alive),
                  onChanged: (value) {
                    setModalState(() {
                      actorId = value;
                      missionVisible = false;
                      correctRoom = false;
                      weaponPresent = false;
                      noWitnesses = false;
                    });
                  },
                ),
                CuboDialogButton(
                  label: missionVisible
                      ? 'OCULTAR MISIÓN'
                      : 'MOSTRAR MI MISIÓN',
                  primary: false,
                  onTap: () {
                    setModalState(() => missionVisible = !missionVisible);
                  },
                ),
                if (missionVisible) ...[
                  const SizedBox(height: 12),
                  if (actor.role != BmRole.asesino)
                    _dialogNotice(
                      'Este jugador no tiene una misión de asesinato.',
                      _accentBlue,
                    )
                  else ...[
                    _secretInfoTile('Objetivo', target?.name ?? 'Sin objetivo'),
                    _secretInfoTile('Habitación', actor.currentRoom ?? '-'),
                    _secretInfoTile('Objeto', actor.currentWeapon ?? '-'),
                    const SizedBox(height: 6),
                    _checkRow(
                      value: correctRoom,
                      text: 'Estamos en la habitación correcta',
                      onChanged: (value) {
                        setModalState(() => correctRoom = value);
                      },
                    ),
                    _checkRow(
                      value: weaponPresent,
                      text: 'El objeto asignado está presente',
                      onChanged: (value) {
                        setModalState(() => weaponPresent = value);
                      },
                    ),
                    _checkRow(
                      value: noWitnesses,
                      text: 'No hay ningún testigo vivo presente',
                      onChanged: (value) {
                        setModalState(() => noWitnesses = value);
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 6),
                CuboDialogButton(
                  label: 'CONFIRMAR ASESINATO',
                  color: _accentRed,
                  onTap: canKill ? confirmKill : null,
                ),
                CuboDialogButton(
                  label: 'CANCELAR',
                  primary: false,
                  onTap: () => Navigator.pop(dialogContext),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showArrestDialog() async {
    final alive = game.alivePlayers;

    if (alive.length < 2) {
      _snack('No quedan suficientes jugadores vivos.');
      return;
    }

    String agentId = alive.first.id;
    String suspectId = alive.firstWhere((p) => p.id != agentId).id;
    bool hasClearProof = true;

    await showCuboDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final suspects = alive.where((p) => p.id != agentId).toList();

            if (!suspects.any((p) => p.id == suspectId)) {
              suspectId = suspects.first.id;
            }

            void confirmArrest() {
              final agent = game.findPlayerById(agentId)!;

              if (agent.role != BmRole.agente) {
                _snack('Este jugador no es un agente.');
                return;
              }

              final message = game.arrestPlayer(
                agentId: agentId,
                suspectId: suspectId,
                hasClearProof: hasClearProof,
              );

              Navigator.pop(dialogContext);
              _update(() {});
              _snack(message);
            }

            return CuboDialogFrame(
              icon: Icons.local_police_rounded,
              title: 'detención',
              children: [
                CuboDialogChoices<String>(
                  label: 'AGENTE QUE ACTÚA',
                  value: agentId,
                  options: _playerChoices(alive),
                  onChanged: (value) => setModalState(() => agentId = value),
                ),
                CuboDialogChoices<String>(
                  label: 'SOSPECHOSO',
                  value: suspectId,
                  options: _playerChoices(suspects),
                  onChanged: (value) => setModalState(() => suspectId = value),
                ),
                _checkRow(
                  value: hasClearProof,
                  text: 'He presenciado el crimen o tengo una prueba clara',
                  onChanged: (value) {
                    setModalState(() => hasClearProof = value);
                  },
                ),
                const SizedBox(height: 6),
                _dialogNotice(
                  hasClearProof
                      ? 'Si el acusado es asesino: 10 minutos sin matar y hasta 40€ para el agente.'
                      : 'Sin prueba clara, la acusación se considerará falsa aunque el sospechoso sea asesino.',
                  hasClearProof ? _accentBlue : _accentRed,
                ),
                const SizedBox(height: 6),
                CuboDialogButton(
                  label: 'DECLARAR DETENCIÓN',
                  onTap: confirmArrest,
                ),
                CuboDialogButton(
                  label: 'CANCELAR',
                  primary: false,
                  onTap: () => Navigator.pop(dialogContext),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showTransferDialog() async {
    final alive = game.alivePlayers;

    if (alive.length < 2) {
      _snack('No hay suficientes jugadores vivos para hacer un trato.');
      return;
    }

    String fromId = alive.first.id;
    String toId = alive.firstWhere((p) => p.id != fromId).id;
    bool transferGood = false;
    String? selectedLotId;
    final amountController = TextEditingController();
    final reasonController = TextEditingController(text: tr('Trato privado'));

    await showCuboDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sender = game.findPlayerById(fromId)!;
            final recipients = alive.where((p) => p.id != fromId).toList();

            if (!recipients.any((p) => p.id == toId)) {
              toId = recipients.first.id;
            }

            if (sender.goods.isNotEmpty &&
                !sender.goods.any((lot) => lot.id == selectedLotId)) {
              selectedLotId = sender.goods.first.id;
            }

            if (sender.goods.isEmpty) {
              selectedLotId = null;
            }

            void confirmTransfer() {
              final reason = reasonController.text.trim().isEmpty
                  ? 'Trato privado'
                  : reasonController.text.trim();

              final message = transferGood
                  ? game.transferGood(
                      fromPlayerId: fromId,
                      toPlayerId: toId,
                      lotId: selectedLotId!,
                      reason: reason,
                    )
                  : game.transferMoney(
                      fromPlayerId: fromId,
                      toPlayerId: toId,
                      amount: int.tryParse(amountController.text.trim()) ?? 0,
                      reason: reason,
                    );

              final success =
                  message.contains('transfiere') || message.contains('entrega');

              if (!success) {
                _snack(message);
                return;
              }

              Navigator.pop(dialogContext);
              _update(() {});
              _snack(message);
            }

            return CuboDialogFrame(
              icon: Icons.handshake_rounded,
              title: 'trato',
              children: [
                CuboDialogChoices<bool>(
                  label: 'QUÉ SE ENTREGA',
                  value: transferGood,
                  options: const [(false, 'DINERO'), (true, 'BIEN')],
                  onChanged: (value) {
                    setModalState(() => transferGood = value);
                  },
                ),
                CuboDialogChoices<String>(
                  label: 'DE',
                  value: fromId,
                  options: _playerChoices(alive),
                  onChanged: (value) {
                    setModalState(() {
                      fromId = value;
                      selectedLotId = null;
                    });
                  },
                ),
                CuboDialogChoices<String>(
                  label: 'PARA',
                  value: toId,
                  options: _playerChoices(recipients),
                  onChanged: (value) => setModalState(() => toId = value),
                ),
                if (!transferGood)
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: _appWhite,
                      fontWeight: FontWeight.w800,
                    ),
                    cursorColor: _appWhite,
                    decoration: _dialogInputDecoration(
                      'Cantidad · disponible ${sender.money}€',
                    ),
                  )
                else if (sender.goods.isEmpty)
                  _dialogNotice(
                    '${sender.name} no posee ningún bien.',
                    _accentRed,
                  )
                else
                  CuboDialogChoices<String>(
                    label: 'BIEN',
                    value: selectedLotId,
                    options: [
                      for (final lot in sender.goods)
                        (lot.id, '${lot.name} · ${lot.value}€'),
                    ],
                    onChanged: (value) {
                      setModalState(() => selectedLotId = value);
                    },
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  style: const TextStyle(
                    color: _appWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: _appWhite,
                  decoration: _dialogInputDecoration(
                    'Motivo: trato, robo, deuda...',
                  ),
                ),
                const SizedBox(height: 6),
                CuboDialogButton(
                  label: 'REGISTRAR CAMBIO',
                  onTap: transferGood && selectedLotId == null
                      ? null
                      : confirmTransfer,
                ),
                CuboDialogButton(
                  label: 'CANCELAR',
                  primary: false,
                  onTap: () => Navigator.pop(dialogContext),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    reasonController.dispose();
  }

  Future<void> _confirmStartFinalAuction() async {
    if (game.alivePlayers.isEmpty) {
      _snack('No queda ningún jugador vivo para participar.');
      return;
    }

    final confirmed = await showCuboDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) => CuboDialogFrame(
        icon: Icons.diamond_rounded,
        title: 'subasta',
        children: [
          const CuboDialogNote(
            'La fase libre terminará y comenzarán 5 lotes con pujas secretas. Después se mostrará el ganador de la herencia.',
          ),
          CuboDialogButton(
            label: 'COMENZAR SUBASTA FINAL',
            onTap: () => Navigator.pop(dialogContext, true),
          ),
          CuboDialogButton(
            label: 'SEGUIR JUGANDO',
            primary: false,
            onTap: () => Navigator.pop(dialogContext, false),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _update(() {
      bidController.clear();
      game.startFinalAuction(lotCount: 5);
    });
  }

  Widget _dialogNotice(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
      decoration: CuboDecorations.glass(radius: CuboRadii.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _accentDot(color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: CuboColors.whiteA(0.80),
                fontSize: 12.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow({
    required bool value,
    required String text,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: CuboRadii.mdAll,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: CuboColors.whiteA(value ? 0.14 : 0.06),
          borderRadius: CuboRadii.mdAll,
          border: Border.all(
            color: value ? CuboColors.whiteA(0.80) : CuboColors.whiteA(0.20),
            width: value ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
              activeColor: _appWhite,
              checkColor: _appBlue,
              side: BorderSide(color: CuboColors.whiteA(0.75), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: _appWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String hint) {
    return CuboInputs.decoration(hintText: tr(hint));
  }
}
