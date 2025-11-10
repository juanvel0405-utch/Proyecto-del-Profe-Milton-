import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:proyectou3/blocs/player_event.dart';
import 'package:proyectou3/blocs/player_load_event.dart';
import 'package:proyectou3/blocs/player_load_states.dart';
import 'package:proyectou3/blocs/player_state.dart';

import '../models/audio_item.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayState> {
  final AudioPlayer audioPlayer;
  final List<AudioItem> canciones;
  StreamSubscription? position,duration,estado;

  PlayerBloc({required this.audioPlayer, required this.canciones})
    : super(InitialState()) {
    on<PlayerLoadEvent>(cargando);
    on<PlayEvent>(reproduciendo);
    on<PauseEvent>(pausando);
    on<PlayPauseEvent>(playPause);
    on<NextEvent>(siguiente);
    on<PrevEvent>(anterior);
    on<SeekEvent>(buscar);
    on<UpdatePositionEvent>(_updatePosition);
    on<UpdateDurationEvent>(_updateDuration);
    setUp();
  }
  
  FutureOr<void> _updatePosition(UpdatePositionEvent event, Emitter<PlayState> emit) {
    if (state is PlayingState) {
      final estadoActual = state as PlayingState;
      emit(PlayingState(
        currentIndex: estadoActual.currentIndex,
        duration: estadoActual.duration,
        position: event.position,
        playing: estadoActual.playing,
      ));
    }
  }
  
  FutureOr<void> _updateDuration(UpdateDurationEvent event, Emitter<PlayState> emit) {
    if (state is PlayingState) {
      final estadoActual = state as PlayingState;
      emit(PlayingState(
        currentIndex: estadoActual.currentIndex,
        duration: event.duration,
        position: estadoActual.position,
        playing: estadoActual.playing,
      ));
    }
  }

  FutureOr<void> cargando(
    PlayerLoadEvent event,
    Emitter<PlayState> emit,
  ) async {
    try {
      emit(LoadingState());
      await audioPlayer.stop();
      await audioPlayer.setSourceAsset(canciones[event.index].assetPath);
      
      // Esperar un momento para que el audio se cargue completamente
      await Future.delayed(Duration(milliseconds: 100));
      
      // Obtener la duración después de que el archivo se haya cargado
      Duration? duration = await audioPlayer.getDuration();
      if (duration == null || duration.inMilliseconds == 0) {
        // Si no se obtiene la duración, esperar un poco más y reintentar
        await Future.delayed(Duration(milliseconds: 200));
        duration = await audioPlayer.getDuration() ?? Duration.zero;
      }
      
      await audioPlayer.resume();
      
      // Obtener la posición actual
      final position = await audioPlayer.getCurrentPosition() ?? Duration.zero;
      
      emit(
        PlayingState(
          currentIndex: event.index,
          duration: duration,
          position: position,
          playing: true,
        ),
      );
    } catch (e) {
      emit(ErrorState("Error: no se puedo cargar el archivo"));
      debugPrint(e.toString());
    }
  }

  FutureOr<void> reproduciendo(PlayEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      try {
        await audioPlayer.resume();
        final PlayingState estadoActual = state as PlayingState;
        emit(estadoActual.copyWith(playing: true));
      } catch(e) {
        emit(ErrorState("Error: no se pudo reproducir el archivo"));
        debugPrint(e.toString());
      }
    }
  }

  FutureOr<void> pausando(PauseEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      try {
        await audioPlayer.pause();
        final PlayingState estadoActual = state as PlayingState;
        emit(PlayingState(
          currentIndex: estadoActual.currentIndex,
          duration: estadoActual.duration,
          position: estadoActual.position,
          playing: false,
        ));
      } catch(e) {
        emit(ErrorState("Error: no se pudo pausar el archivo"));
        debugPrint(e.toString());
      }
    }
  }

  FutureOr<void> playPause(PlayPauseEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      final PlayingState estadoActual = state as PlayingState;
      if (estadoActual.playing) {
        add(PauseEvent());
      } else {
        add(PlayEvent());
      }
    }
  }

  FutureOr<void> siguiente(NextEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      final PlayingState estadoActual = state as PlayingState;
      final siguienteIndice = (estadoActual.currentIndex + 1) % canciones.length;
      add(PlayerLoadEvent(siguienteIndice));
    }
  }

  FutureOr<void> anterior(PrevEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      final PlayingState estadoActual = state as PlayingState;
      final anteriorIndice = (estadoActual.currentIndex - 1 + canciones.length) % canciones.length;
      add(PlayerLoadEvent(anteriorIndice));
    }
  }

  FutureOr<void> buscar(SeekEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      try {
        await audioPlayer.seek(event.position);
        final PlayingState estadoActual = state as PlayingState;
        // Crear un nuevo estado para forzar la actualización
        emit(PlayingState(
          currentIndex: estadoActual.currentIndex,
          duration: estadoActual.duration,
          position: event.position,
          playing: estadoActual.playing,
        ));
      } catch(e) {
        emit(ErrorState("Error: no se pudo buscar la posición"));
        debugPrint(e.toString());
      }
    }
  }

  void setUp() {
    position = audioPlayer.onPositionChanged.listen((newPosition) {
      final currentState = state;
      if (currentState is PlayingState) {
        // Usar eventos para actualizar la posición de forma segura
        add(UpdatePositionEvent(newPosition));
      }
    });
    duration = audioPlayer.onDurationChanged.listen((newDuration) {
      final currentState = state;
      if (currentState is PlayingState && newDuration.inMilliseconds > 0) {
        final estadoActual = currentState as PlayingState;
        // Solo actualizar si la duración es válida y diferente
        if (estadoActual.duration.inMilliseconds != newDuration.inMilliseconds) {
          add(UpdateDurationEvent(newDuration));
        }
      }
    });
    estado = audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (state is PlayingState) {
        final PlayingState estadoActual = state as PlayingState;
        if (playerState == PlayerState.playing && !estadoActual.playing) {
          emit(PlayingState(
            currentIndex: estadoActual.currentIndex,
            duration: estadoActual.duration,
            position: estadoActual.position,
            playing: true,
          ));
        } else if (playerState == PlayerState.paused && estadoActual.playing) {
          emit(PlayingState(
            currentIndex: estadoActual.currentIndex,
            duration: estadoActual.duration,
            position: estadoActual.position,
            playing: false,
          ));
        } else if (playerState == PlayerState.completed) {
          // Cuando termina la canción, pasar a la siguiente
          final siguienteIndice = (estadoActual.currentIndex + 1) % canciones.length;
          add(PlayerLoadEvent(siguienteIndice));
        }
      }
    });
  }

  @override
  Future<void> close() {
    // TODO: implement close
    estado?.cancel();
    position?.cancel();
    duration?.cancel();
    audioPlayer.dispose();
    return super.close();
  }
} // end class