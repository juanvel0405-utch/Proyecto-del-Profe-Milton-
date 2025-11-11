import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proyectou3/views/swiper.dart';
import '../blocs/player_load_event.dart';
import '../blocs/player_load_states.dart';
import '../blocs/player_state.dart';
import '../blocs/playerbloc.dart';
import '../models/audio_item.dart';
import 'audio_settings_sheet.dart';

class Player extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const Player({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  Color? wormColor;
  PageController? pageController;
  int _lastIndex = 0;
  final List<AudioItem> canciones = [
    AudioItem(
      "allthat.mp3",
      "All that",
      "Mayelo",
      "assets/allthat_colored.jpg",
    ),
    AudioItem("love.mp3",
        "Love",
        "Diego",
        "assets/love_colored.jpg"),
    AudioItem(
      "thejazzpiano.mp3",
      "Jazz Piano",
      "Jazira",
      "assets/thejazzpiano_colored.jpg",
    ),
  ];
  late final PlayerBloc bloc = PlayerBloc(
    audioPlayer: widget.audioPlayer,
    canciones: canciones,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    wormColor = Color(0xffda1cd2);
    pageController = PageController(viewportFraction: .8, initialPage: 0);
    bloc.add(PlayerLoadEvent(0));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocListener<PlayerBloc, PlayState>(
        listener: (context, state) {
          // Sincronizar PageController cuando cambia el índice desde los botones
          if (state is PlayingState) {
            if (state.currentIndex != _lastIndex) {
              _lastIndex = state.currentIndex;
              if (pageController != null &&
                  pageController!.hasClients &&
                  (pageController!.page?.round() ?? -1) != state.currentIndex) {
                pageController!.animateToPage(
                  state.currentIndex,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 56,
            backgroundColor: Color(0xff3966da),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AudioSettingsSheet(),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Swiper(
                  pageController: pageController!,
                  audioList: canciones,
                  color: wormColor!,
                  bloc: bloc,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController?.dispose();
    bloc.close();
    super.dispose();
  }
} // end class
