import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../blocs/player_load_event.dart';
import '../blocs/player_load_states.dart';
import '../blocs/player_state.dart';
import '../blocs/playerbloc.dart';
import '../models/audio_item.dart';

class Swiper extends StatelessWidget {
  final PageController pageController;
  final List<AudioItem> audioList;
  final Color color;
  final PlayerBloc bloc;

  const Swiper({
    Key? key,
    required this.pageController,
    required this.audioList,
    required this.color,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        return Column(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .20,
              child: PageView.builder(
                controller: pageController,
                itemCount: audioList.length,
                onPageChanged: (indice) {
                  final actual = bloc.state;
                  if (actual is PlayingState && indice != actual.position) {
                    bloc.add(PlayerLoadEvent(indice));
                  }
                },
                itemBuilder: (contex, index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      audioList[index].imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            //Divider(),
            //Spacer()
            SizedBox(height: 15),
            SmoothPageIndicator(
              controller: pageController,
              count: audioList.length,
              axisDirection: Axis.horizontal,
              effect: SlideEffect(
                spacing: 8.0,
                radius: 4.0,
                dotWidth: 17.0,
                dotHeight: 17.0,
                paintStyle: PaintingStyle.stroke,
                strokeWidth: 1.5,
                dotColor: Colors.grey,
                activeDotColor: color,
              ),
            ),
            SizedBox(height: 30),
            // Mostrar título y artista de la canción actual
            if (state is PlayingState)
              _buildSongInfo(audioList[(state as PlayingState).currentIndex])
            else if (state is LoadingState)
              _buildSongInfo(audioList[0])
            else
              _buildSongInfo(audioList[0]),
            SizedBox(height: 30),
            // Barra de progreso y controles
            if (state is PlayingState)
              _buildPlayerControls(context, state as PlayingState)
            else
              SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Widget _buildSongInfo(AudioItem audioItem) {
    return Column(
      children: [
        Text(
          audioItem.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          audioItem.artist,
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildPlayerControls(BuildContext context, PlayingState state) {
    return _PlayerControlsWidget(state: state, bloc: bloc);
  }
}

// Widget de estado para manejar el slider con estado local durante el arrastre
class _PlayerControlsWidget extends StatefulWidget {
  final PlayingState state;
  final PlayerBloc bloc;

  const _PlayerControlsWidget({
    Key? key,
    required this.state,
    required this.bloc,
  }) : super(key: key);

  @override
  _PlayerControlsWidgetState createState() => _PlayerControlsWidgetState();
}

class _PlayerControlsWidgetState extends State<_PlayerControlsWidget> {
  double? _dragValue;
  bool _isDragging = false;

  @override
  void didUpdateWidget(_PlayerControlsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambió la canción (currentIndex), resetear el estado de arrastre
    if (widget.state.currentIndex != oldWidget.state.currentIndex) {
      setState(() {
        _isDragging = false;
        _dragValue = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar BlocBuilder para escuchar cambios en tiempo real
    return BlocBuilder<PlayerBloc, PlayState>(
      bloc: widget.bloc,
      builder: (context, state) {
        if (state is! PlayingState) {
          return SizedBox.shrink();
        }

        final duration = state.duration;
        // Usar valor de arrastre si está arrastrando, sino usar la posición del estado
        final position = _isDragging && _dragValue != null
            ? Duration(milliseconds: _dragValue!.toInt())
            : state.position;

        final isPlaying = state.playing;

        // Formatear tiempo
        String formatDuration(Duration duration) {
          String twoDigits(int n) => n.toString().padLeft(2, '0');
          final minutes = twoDigits(duration.inMinutes.remainder(60));
          final seconds = twoDigits(duration.inSeconds.remainder(60));
          return '$minutes:$seconds';
        }

        // Calcular el valor del slider
        // Si la duración es 0 o muy pequeña, usar un valor por defecto temporal
        final maxDuration = duration.inMilliseconds > 0
            ? duration.inMilliseconds.toDouble()
            : (position.inMilliseconds > 0
                  ? position.inMilliseconds * 2.0
                  : 100.0); // Valor temporal hasta que se obtenga la duración real

        final currentValue = _isDragging && _dragValue != null
            ? _dragValue!.clamp(0.0, maxDuration)
            : (maxDuration > 0
                  ? position.inMilliseconds.toDouble().clamp(0.0, maxDuration)
                  : 0.0);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Barra de progreso
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white38,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withValues(alpha: 0.2),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: currentValue.clamp(0.0, maxDuration),
                  max: maxDuration,
                  onChanged: (value) {
                    // Cuando el usuario arrastra, actualizar el valor local
                    setState(() {
                      _isDragging = true;
                      _dragValue = value.clamp(0.0, maxDuration);
                    });
                  },
                  onChangeEnd: (value) {
                    // Cuando el usuario suelta, hacer el seek real
                    setState(() {
                      _isDragging = false;
                      _dragValue = null;
                    });
                    widget.bloc.add(
                      SeekEvent(Duration(milliseconds: value.toInt())),
                    );
                  },
                ),
              ),
              // Tiempos
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(position),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      formatDuration(duration),
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              // Botones de control con CircularProgressIndicator
              Stack(
                alignment: Alignment.center,
                children: [
                  // CircularProgressIndicator de fondo
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: duration.inMilliseconds > 0
                          ? (position.inMilliseconds / duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                          : 0.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3.0,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  // Botones de control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón anterior
                      IconButton(
                        onPressed: () {
                          widget.bloc.add(PrevEvent());
                        },
                        icon: Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 20),
                      // Botón play/pause
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: IconButton(
                          onPressed: () {
                            widget.bloc.add(PlayPauseEvent());
                          },
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                          padding: EdgeInsets.all(12),
                        ),
                      ),
                      SizedBox(width: 20),
                      // Botón siguiente
                      IconButton(
                        onPressed: () {
                          widget.bloc.add(NextEvent());
                        },
                        icon: Icon(
                          Icons.skip_next,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
