import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyectou3/blocs/player_load_event.dart';
import 'package:proyectou3/blocs/player_load_states.dart';
import 'package:proyectou3/blocs/playerbloc.dart';

import '../blocs/player_state.dart';

class AudioSettingsSheet extends StatelessWidget {
  const AudioSettingsSheet({Key? key}) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = const Color(0xFF1F2330);
    final Color panel = const Color(0xFF2A2F3D);
    final Color primary = const Color(0xFF8CB4FF);
    final TextStyle titleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    final TextStyle labelStyle = const TextStyle(
      color: Colors.white70,
      fontSize: 14,
    );

    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        final isPlayingState = state is PlayingState;
        final volume = isPlayingState ? (state as PlayingState).volume : 1.0;
        final playbackRate = isPlayingState ? (state as PlayingState).playbackRate : 1.0;
        final playing = isPlayingState ? (state as PlayingState).playing : false;
        final duration = isPlayingState ? (state as PlayingState).duration : Duration.zero;
        final position = isPlayingState ? (state as PlayingState).position : Duration.zero;

        return Container(
          color: bg,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Configuración de Audio', style: titleStyle),
                  const SizedBox(height: 12),
                  // Volumen
                  Row(
                    children: [
                      Icon(Icons.volume_down, color: Colors.white70),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: primary,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: primary,
                          ),
                          child: Slider(
                            value: volume,
                            min: 0,
                            max: 1,
                            onChanged: (v) {
                              context.read<PlayerBloc>().add(SetVolumeEvent(v));
                            },
                          ),
                        ),
                      ),
                      Icon(Icons.volume_up, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Volumen: ${(volume * 100).toInt()}%', style: labelStyle),
                  const SizedBox(height: 16),
                  // Velocidad
                  Text('Velocidad de Reproducción', style: titleStyle.copyWith(fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _SpeedChip(
                        text: '0.5x',
                        rate: 0.5,
                        selected: playbackRate == 0.5,
                        bloc: context.read<PlayerBloc>(),
                      ),
                      _SpeedChip(
                        text: '0.75x',
                        rate: 0.75,
                        selected: playbackRate == 0.75,
                        bloc: context.read<PlayerBloc>(),
                      ),
                      _SpeedChip(
                        text: '1.0x',
                        rate: 1.0,
                        selected: playbackRate == 1.0,
                        bloc: context.read<PlayerBloc>(),
                      ),
                      _SpeedChip(
                        text: '1.25x',
                        rate: 1.25,
                        selected: playbackRate == 1.25,
                        bloc: context.read<PlayerBloc>(),
                      ),
                      _SpeedChip(
                        text: '1.5x',
                        rate: 1.5,
                        selected: playbackRate == 1.5,
                        bloc: context.read<PlayerBloc>(),
                      ),
                      _SpeedChip(
                        text: '2.0x',
                        rate: 2.0,
                        selected: playbackRate == 2.0,
                        bloc: context.read<PlayerBloc>(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Información del audio
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Información del Audio', style: titleStyle.copyWith(fontSize: 16)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _InfoRow(
                              label: 'Estado',
                              value: playing ? 'Reproduciendo' : 'Pausado',
                            ),
                            _InfoRow(
                              label: 'Duración',
                              value: _formatDuration(duration),
                            ),
                            _InfoRow(
                              label: 'Posición',
                              value: _formatDuration(position),
                            ),
                          ],
                        ),
                      ],
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
}

class _SpeedChip extends StatelessWidget {
  final String text;
  final double rate;
  final bool selected;
  final PlayerBloc bloc;

  const _SpeedChip({
    Key? key,
    required this.text,
    required this.rate,
    required this.selected,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF8CB4FF);
    return GestureDetector(
      onTap: () {
        bloc.add(SetPlaybackRateEvent(rate));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.5) : Colors.transparent,
          border: Border.all(color: selected ? primary : Colors.white30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
