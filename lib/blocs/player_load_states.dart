import 'package:proyectou3/blocs/player_state.dart';

class InitialState extends PlayState {}

class LoadingState extends PlayState {}

class PlayingState extends PlayState {
  final int currentIndex;
  final Duration duration;
  final Duration position;
  final bool playing;
  final double volume;
  final double playbackRate;

  PlayingState({
    required this.currentIndex,
    required this.duration,
    required this.position,
    required this.playing,
    this.volume = 1.0,
    this.playbackRate = 1.0,
  });

  @override
  List<dynamic> get props => [currentIndex, duration, position, playing, volume, playbackRate];

  PlayingState copyWith({
    int? currentIndex,
    Duration? duration,
    Duration? position,
    bool? playing,
    double? volume,
    double? playbackRate,
  }) {
    return PlayingState(
      currentIndex: currentIndex ?? this.currentIndex,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      playing: playing ?? this.playing,
      volume: volume ?? this.volume,
      playbackRate: playbackRate ?? this.playbackRate,
    );
  }
}

class ErrorState extends PlayState{
  final String msg;
  const ErrorState(this.msg);
  @override
  List<Object> get props => [msg];
}

class PlayPauseState extends PlayState {
  @override
  List<Object> get props => [];
}
