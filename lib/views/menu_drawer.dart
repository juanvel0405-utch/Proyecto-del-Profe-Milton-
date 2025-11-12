import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:proyectou3/blocs/player_load_event.dart';
import 'package:proyectou3/blocs/player_load_states.dart';
import 'package:proyectou3/blocs/playerbloc.dart';
import 'package:proyectou3/models/audio_item.dart';
import 'package:proyectou3/views/audio_settings_sheet.dart';

import '../blocs/player_state.dart';

class MenuDrawer extends StatelessWidget {
  final List<AudioItem> canciones;
  final GlobalKey sliderMenuKey;
  final VoidCallback? onCloseDrawer;

  const MenuDrawer({
    Key? key,
    required this.canciones,
    required this.sliderMenuKey,
    this.onCloseDrawer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        final currentIndex = state is PlayingState ? (state as PlayingState).currentIndex : 0;
        
        return Material(
          color: const Color(0xFF1F2330),
          child: SafeArea(
            child: Column(
              children: [
                // Imagen del header
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xff3966da),
                        const Color(0xff28a0e5),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Imagen de fondo
                      Positioned.fill(
                        child: Image.asset(
                          'assets/iconoapp.png',
                          fit: BoxFit.cover,
                          opacity: const AlwaysStoppedAnimation(0.3),
                        ),
                      ),
                      // Contenido sobre la imagen
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/iconoapp.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Reproductor de Audio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Proyecto U3',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de canciones
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: canciones.length,
                    itemBuilder: (context, index) {
                      final cancion = canciones[index];
                      final isSelected = index == currentIndex;
                      
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              cancion.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          cancion.title,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF8CB4FF) : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          cancion.artist,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF8CB4FF).withOpacity(0.7) : Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.play_circle_filled,
                                color: Color(0xFF8CB4FF),
                                size: 28,
                              )
                            : const Icon(
                                Icons.music_note,
                                color: Colors.white54,
                                size: 24,
                              ),
                        selected: isSelected,
                        selectedTileColor: const Color(0xFF2A2F3D).withOpacity(0.5),
                        onTap: () {
                          // Cerrar el drawer
                          if (onCloseDrawer != null) {
                            onCloseDrawer!();
                          }
                          // Cargar la canción seleccionada
                          context.read<PlayerBloc>().add(PlayerLoadEvent(index));
                        },
                      );
                    },
                  ),
                ),
                // Footer con información y botón de settings
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2F3D),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.music_note,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${canciones.length} canciones',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Botón de configuración
                      IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white70,
                          size: 24,
                        ),
                        onPressed: () {
                          // Capturar el BLoC antes de cerrar el drawer
                          final bloc = context.read<PlayerBloc>();
                          
                          // Cerrar el drawer primero
                          if (onCloseDrawer != null) {
                            onCloseDrawer!();
                          }
                          
                          // Abrir settings después de un pequeño delay
                          Future.delayed(const Duration(milliseconds: 300), () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (modalContext) => BlocProvider.value(
                                value: bloc,
                                child: const AudioSettingsSheet(),
                              ),
                            );
                          });
                        },
                        tooltip: 'Configuración',
                      ),
                    ],
                  ),
                ),
                // Controles de reproducción
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1E2E),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón anterior
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          context.read<PlayerBloc>().add(PrevEvent());
                        },
                      ),
                      // Botón play/pause
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8CB4FF),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8CB4FF).withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            state is PlayingState && (state as PlayingState).playing
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            context.read<PlayerBloc>().add(PlayPauseEvent());
                          },
                        ),
                      ),
                      // Botón siguiente
                      IconButton(
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          context.read<PlayerBloc>().add(NextEvent());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

