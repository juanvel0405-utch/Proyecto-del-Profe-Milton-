import 'package:equatable/equatable.dart';
import 'dart:async';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<dynamic> get props => [];
}

// Eventos internos para actualizar posición y duración
class UpdatePositionEvent extends PlayerEvent {
  final Duration position;
  const UpdatePositionEvent(this.position);
  
  @override
  List<Object> get props => [position];
}

class UpdateDurationEvent extends PlayerEvent {
  final Duration duration;
  const UpdateDurationEvent(this.duration);
  
  @override
  List<Object> get props => [duration];
}
