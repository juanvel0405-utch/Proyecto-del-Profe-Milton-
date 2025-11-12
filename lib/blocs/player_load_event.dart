import 'package:proyectou3/blocs/player_event.dart';

class PlayerLoadEvent extends PlayerEvent {
  final int index;

  PlayerLoadEvent(this.index);

  @override
  List<Object> get props => [index];
}

class PlayEvent extends PlayerEvent {

}


class PauseEvent extends PlayerEvent {

}

class NextEvent extends PlayerEvent {

}

class PrevEvent extends PlayerEvent {

}

class PlayPauseEvent extends PlayerEvent{

}
class SeekEvent extends PlayerEvent{
  final Duration position;
  const SeekEvent(this.position);
  List<Object> get props => [position];
}
// Funcionalidades de settings PUNTO 4
class SetVolumeEvent extends PlayerEvent {
  final double volume;
  const SetVolumeEvent(this.volume);
  @override
  List<Object> get props => [volume];
}

// Funcionalidades de settings PUNTO 4
class SetPlaybackRateEvent extends PlayerEvent {
  final double rate;
  const SetPlaybackRateEvent(this.rate);
  @override
  List<Object> get props => [rate];
}