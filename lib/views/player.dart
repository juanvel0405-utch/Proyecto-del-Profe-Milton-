import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:proyectou3/views/swiper.dart';
import '../blocs/player_load_event.dart';
import '../blocs/player_load_states.dart';
import '../blocs/player_state.dart';
import '../blocs/playerbloc.dart';
import '../models/audio_item.dart';
import 'audio_settings_sheet.dart';
import 'menu_drawer.dart';

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
  final GlobalKey<SliderDrawerState> sliderDrawerKey = GlobalKey<SliderDrawerState>();
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
          // Sincronizar PageController cuando cambia el índice
          if (state is PlayingState) {
            final currentPageIndex = pageController?.page?.round() ?? -1;
            
            // Solo animar si el índice cambió Y el PageController no está ya en esa página
            if (state.currentIndex != _lastIndex || currentPageIndex != state.currentIndex) {
              _lastIndex = state.currentIndex;
              
              if (pageController != null && pageController!.hasClients) {
                // Usar jumpToPage para cambios grandes, animateToPage para cambios pequeños
                final difference = (state.currentIndex - currentPageIndex).abs();
                
                if (difference > 1 || currentPageIndex == -1) {
                  // Salto directo para cambios grandes o inicial
                  pageController!.jumpToPage(state.currentIndex);
                } else {
                  // Animación para cambios de una página
                  pageController!.animateToPage(
                    state.currentIndex,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }
            }
          }
        },
        child: SliderDrawer(
          key: sliderDrawerKey,
          appBar: SliderAppBar(
            appBarHeight: 0,
            appBarColor: Colors.transparent,
          ),
          slider: MenuDrawer(
            canciones: canciones,
            sliderMenuKey: sliderDrawerKey,
            onCloseDrawer: () {
              sliderDrawerKey.currentState?.closeSlider();
            },
          ),
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 56,
              backgroundColor: const Color(0xff3966da),
              title: const Text(
                'Reproductor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  final drawerState = sliderDrawerKey.currentState;
                  if (drawerState != null) {
                    if (drawerState.isDrawerOpen) {
                      drawerState.closeSlider();
                    } else {
                      drawerState.openSlider();
                    }
                  }
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => BlocProvider.value(
                        value: bloc,
                        child: const AudioSettingsSheet(),
                      ),
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
