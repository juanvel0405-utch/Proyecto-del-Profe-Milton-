import 'package:flutter/material.dart';

class AudioSettingsSheet extends StatelessWidget {
  const AudioSettingsSheet({Key? key}) : super(key: key);

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
                        value: 1.0,
                        min: 0,
                        max: 1,
                        onChanged: (v) {},
                      ),
                    ),
                  ),
                  Icon(Icons.volume_up, color: Colors.white70),
                ],
              ),
              const SizedBox(height: 4),
              Text('Volumen: 100%', style: labelStyle),
              const SizedBox(height: 16),
              // Velocidad
              Text('Velocidad de Reproducción', style: titleStyle.copyWith(fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _SpeedChip(text: '0.5x'),
                  _SpeedChip(text: '0.75x'),
                  _SpeedChip(text: '1.0x', selected: true),
                  _SpeedChip(text: '1.25x'),
                  _SpeedChip(text: '1.5x'),
                  _SpeedChip(text: '2.0x'),
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
                      children: const [
                        _InfoRow(label: 'Estado', value: 'Pausado'),
                        _InfoRow(label: 'Duración', value: '00:00'),
                        _InfoRow(label: 'Posición', value: '00:00'),
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
  }
}

class _SpeedChip extends StatelessWidget {
  final String text;
  final bool selected;
  const _SpeedChip({Key? key, required this.text, this.selected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF8CB4FF);
    return Container(
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


