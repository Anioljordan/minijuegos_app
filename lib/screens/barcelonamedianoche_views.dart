part of 'barcelonamedianoche_screen.dart';

/// Fases de la partida ya empezada: la noche, la subasta final y el
/// resultado, con sus fichas de jugador y botones de acción.
extension _BmViews on _BarcelonaMedianocheScreenState {
  Widget _buildGameView() {
    final compact = _isCompactScreen;

    return SingleChildScrollView(
      key: const ValueKey('playing'),
      padding: EdgeInsets.fromLTRB(
        compact ? 13 : 18,
        compact ? 11 : 18,
        compact ? 13 : 18,
        compact ? 20 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _screenHeader(title: 'Barcelona Medianoche'),
          SizedBox(height: compact ? 12 : 18),
          _sectionTitle('estado de la noche'),
          const SizedBox(height: 10),
          ...game.players.map(_playerCard),
          SizedBox(height: compact ? 14 : 18),
          _sectionTitle('acciones'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  title: 'Asesinato',
                  subtitle: 'Confirma una misión en secreto.',
                  icon: Icons.local_fire_department_rounded,
                  color: _accentRed,
                  onTap: _showKillDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  title: 'Detención',
                  subtitle: 'Un agente acusa con pruebas.',
                  icon: Icons.local_police_rounded,
                  color: _accentBlue,
                  onTap: _showArrestDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  title: 'Trato o robo',
                  subtitle: 'Mueve dinero o bienes.',
                  icon: Icons.handshake_rounded,
                  color: _accentPurple,
                  onTap: _showTransferDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  title: 'Subasta final',
                  subtitle: 'Comienza las pujas secretas.',
                  icon: Icons.diamond_rounded,
                  color: _accentGold,
                  onTap: _confirmStartFinalAuction,
                  darkForeground: true,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 16 : 20),
          _sectionTitle('registro público'),
          const SizedBox(height: 10),
          _panel(
            child: game.log.isEmpty
                ? Text(
                    'Todavía no ha ocurrido nada.',
                    style: TextStyle(color: _appWhite.withOpacity(0.70)),
                  )
                : Column(
                    children: game.log
                        .take(14)
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(
                                    Icons.circle_rounded,
                                    size: 8,
                                    color: _accentRed,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry,
                                    style: TextStyle(
                                      color: _appWhite.withOpacity(0.84),
                                      height: 1.35,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionView() {
    final compact = _isCompactScreen;
    final lot = game.currentAuctionLot;
    final bidder = game.currentBidder;

    return SingleChildScrollView(
      key: ValueKey(
        'auction_${game.currentLotIndex}_${game.currentBidderIndex}_${game.auctionRoundResolved}',
      ),
      padding: EdgeInsets.fromLTRB(
        compact ? 13 : 18,
        compact ? 11 : 18,
        compact ? 13 : 18,
        compact ? 20 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _screenHeader(
            title: 'subasta final',
            subtitle: lot == null
                ? 'La subasta ha terminado.'
                : 'Lote ${game.currentLotIndex + 1} de ${game.finalAuctionLots.length} · las pujas son secretas.',
          ),
          const SizedBox(height: 18),
          if (lot != null)
            CuboCardSwitcher(
              child: CuboHeroCard(
                key: ValueKey('lot_${game.currentLotIndex}'),
                chip:
                    '${game.currentLotIndex + 1}/${game.finalAuctionLots.length}',
                chipIcon: Icons.diamond_rounded,
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _accentGold.withValues(alpha: 0.22),
                        border: Border.all(color: _accentGold, width: 2.2),
                      ),
                      child: const Icon(
                        Icons.diamond_rounded,
                        color: CuboColors.blueInk,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr(lot.name).toLowerCase(),
                      textAlign: TextAlign.center,
                      style: CuboText.title(
                        size: 32,
                        color: CuboColors.blueInk,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Valor real: ${lot.value}€',
                      style: CuboText.label(size: 16),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          if (!game.auctionRoundResolved && bidder != null)
            _panel(
              child: Column(
                children: [
                  const Icon(
                    Icons.phone_android_rounded,
                    color: _appWhite,
                    size: 34,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'pasa el móvil a\n${bidder.name.toLowerCase()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _appWhite,
                      fontSize: 30,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Disponible: ${bidder.money}€',
                    style: TextStyle(
                      color: _appWhite.withOpacity(0.68),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bidController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: const TextStyle(
                      color: _appWhite,
                      fontWeight: FontWeight.w900,
                    ),
                    cursorColor: _appWhite,
                    decoration: CuboInputs.decoration(
                      hintText: tr('0 = no pujar'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitAuctionBid,
                      style: _mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'GUARDAR PUJA Y OCULTAR',
                          style: TextStyle(
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
          if (game.auctionRoundResolved)
            _panel(
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: _accentGold,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game.lastAuctionResult,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _appWhite,
                      fontSize: 21,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        bidController.clear();
                        _update(game.nextAuctionLotOrFinish);
                      },
                      style: _mainButtonStyle(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          game.isLastAuctionLot
                              ? 'VER RESULTADO FINAL'
                              : 'SIGUIENTE LOTE',
                          style: const TextStyle(
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
      ),
    );
  }

  Widget _buildEndView() {
    final compact = _isCompactScreen;
    final ranking = game.ranking;
    final winner = ranking.isNotEmpty ? ranking.first : null;

    return SingleChildScrollView(
      key: const ValueKey('ended'),
      padding: EdgeInsets.fromLTRB(
        compact ? 13 : 18,
        compact ? 11 : 18,
        compact ? 13 : 18,
        compact ? 20 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _screenHeader(
            title: 'resultado final',
            subtitle: 'La noche ha terminado. La fortuna ya tiene dueño.',
            illustration: 'bcn_medianoche',
          ),
          const SizedBox(height: 18),
          if (winner != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
              decoration: BoxDecoration(
                color: _accentGold,
                borderRadius: CuboRadii.xlAll,
                border: Border.all(color: _appWhite, width: 2.5),
                boxShadow: CuboShadows.soft,
              ),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: _appWhite,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: _appBlue,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'GANA LA HERENCIA',
                    style: TextStyle(
                      color: _appBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    winner.name.toLowerCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _appBlue,
                      fontSize: 42,
                      height: 0.9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${winner.totalWealth}€ de fortuna total',
                    style: const TextStyle(
                      color: _appBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _sectionTitle('clasificación'),
          const SizedBox(height: 10),
          _panel(
            child: Column(
              children: ranking.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: CuboDecorations.glass(
                    radius: CuboRadii.md,
                    selected: index == 0,
                    accent: _accentGold,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index == 0 ? _accentGold : _appWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: const TextStyle(
                                color: _appWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${player.role.label} · ${player.money}€ efectivo · ${player.goodsValue}€ bienes',
                              style: TextStyle(
                                color: _appWhite.withOpacity(0.62),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${player.totalWealth}€',
                        style: const TextStyle(
                          color: _accentGold,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (game.eliminatedPlayers.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle('eliminados'),
            const SizedBox(height: 10),
            _panel(
              child: Column(
                children: game.eliminatedPlayers.map((player) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: _appWhite.withOpacity(0.55),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${player.name} · ${player.role.label}',
                            style: TextStyle(
                              color: _appWhite.withOpacity(0.62),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _restartSamePlayers,
              style: _mainButtonStyle(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'REPETIR · MISMOS JUGADORES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _restartDifferentPlayers,
              style: _secondaryButtonStyle(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text(
                  'CAMBIAR JUGADORES',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: _secondaryButtonStyle(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text(
                  'MENÚ PRINCIPAL',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerCard(BmPlayer player) {
    final remaining = player.detentionRemaining;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: player.isAlive
          ? CuboDecorations.glass(radius: CuboRadii.md)
          : BoxDecoration(
              color: CuboColors.whiteA(0.04),
              borderRadius: CuboRadii.mdAll,
              border: Border.all(color: CuboColors.whiteA(0.14), width: 1.2),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _accentDot(
                !player.isAlive
                    ? CuboColors.whiteA(0.35)
                    : player.isDetained
                    ? _accentBlue
                    : _accentGreen,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  player.name,
                  style: TextStyle(
                    color: player.isAlive
                        ? _appWhite
                        : _appWhite.withOpacity(0.48),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _statusPill(player),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _miniPill('${player.money}€ efectivo'),
              _miniPill('${player.goodsValue}€ bienes'),
              _miniPill('${player.totalWealth}€ total'),
            ],
          ),
          if (player.isDetained) ...[
            const SizedBox(height: 9),
            Text(
              'No puede asesinar durante ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: _accentBlue,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          if (player.goods.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              player.goods.map((lot) => lot.name).join(' · '),
              style: TextStyle(
                color: _appWhite.withOpacity(0.62),
                fontSize: 11.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPill(BmPlayer player) {
    String text;
    Color color;

    if (!player.isAlive) {
      text = 'Eliminado';
      color = _appWhite.withOpacity(0.55);
    } else if (player.isDetained) {
      text = 'Detenido';
      color = _accentBlue;
    } else {
      text = 'Activo';
      color = _accentGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.3),
      ),
      child: Text(
        tr(text).toUpperCase(),
        style: const TextStyle(
          color: _appWhite,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool darkForeground = false,
  }) {
    final compact = _isCompactScreen;
    final foreground = darkForeground ? _appBlue : _appWhite;

    return AspectRatio(
      aspectRatio: compact ? 1.28 : 1.18,
      child: Material(
        color: color,
        shape: const RoundedRectangleBorder(borderRadius: CuboRadii.lgAll),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(compact ? 10 : 13),
            decoration: BoxDecoration(
              borderRadius: CuboRadii.lgAll,
              border: Border.all(color: CuboColors.whiteA(0.32), width: 1.6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: compact ? 46 : 54,
                  height: compact ? 46 : 54,
                  decoration: BoxDecoration(
                    color: darkForeground
                        ? _appBlue.withOpacity(0.12)
                        : _appWhite.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: foreground.withOpacity(0.55),
                      width: 1.8,
                    ),
                  ),
                  child: Icon(icon, color: foreground, size: compact ? 25 : 29),
                ),
                SizedBox(height: compact ? 8 : 10),
                SizedBox(
                  width: double.infinity,
                  child: _singleLineResponsiveText(
                    tr(title).toUpperCase(),
                    alignment: Alignment.center,
                    style: TextStyle(
                      color: foreground,
                      fontSize: compact ? 11.5 : 13,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 4 : 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground.withOpacity(0.78),
                    fontSize: compact ? 9.5 : 10.5,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CuboColors.whiteA(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: CuboColors.whiteA(0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _appWhite.withOpacity(0.82),
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
