import 'package:proyectou3/blocs/player_state.dart';

class InitialState extends PlayState {}

class LoadingState extends PlayState {}

class PlayingState extends PlayState {
  final int currentIndex;
  final Duration duration;
  final Duration position;
  final bool playing;

  PlayingState({
    required this.currentIndex,
    required this.duration,
    required this.position,
    required this.playing,
  });

  @override
  List<dynamic> get props => [currentIndex, duration, position, playing];

  PlayingState copyWith({
    int? currentIndex,
    Duration? duration,
    Duration? position,
    bool? playing,}
  ) {
    return PlayingState(
      currentIndex: currentIndex ?? this.currentIndex,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      playing: playing ?? this.playing,
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
