import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/providers/film_provider.dart';
import 'package:film_randomizer/util/random_utilities.dart';
import 'package:film_randomizer/generated/localization_accessors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class RandomizeScreen extends StatefulWidget {
  const RandomizeScreen({super.key});

  @override
  State<RandomizeScreen> createState() => _RandomizeScreenState();
}

class _RandomizeScreenState extends State<RandomizeScreen> with SingleTickerProviderStateMixin {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create();
  List films = [];
  
  int? selectedFilmIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final filmProvider = Provider.of<FilmProvider>(context);
    if (filmProvider.films == null || filmProvider.films!.length < 2){
      Fluttertoast.showToast(msg:"Add films first!");
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(L10nAccessor.get(context, "randomizer_page")),
      ),
      body: Column(
        children: [
          _buildControls(context, filmProvider),
          Expanded(
            flex: 5,
            child: _buildFilmRandomList(context, filmProvider),
          ),
        ],
      ),
      floatingActionButton: _buildRandomizeButton(context, filmProvider),
    );
  }

  Widget _buildControls(BuildContext context, FilmProvider filmProvider) {
    return Container();
  }

  Widget _buildFilmRandomList(BuildContext context, FilmProvider filmProvider) {
    return Stack(
      children: [
        ScrollablePositionedList.builder(
          itemCount: films.length + 1,
          itemScrollController: itemScrollController,
          scrollOffsetController: scrollOffsetController,
          itemPositionsListener: itemPositionsListener,
          scrollOffsetListener: scrollOffsetListener,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            if (index < films.length) {
              Film film = films.elementAt(index);
              return _buildFilmListEntry(index, context, film);
            }
            else {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
              );
            }
          },
        ),
        _buildOverlay(context),
      ],
    );
  }

  Container _buildFilmListEntry(int index, BuildContext context, Film film) {
    bool isSelected = index == selectedFilmIndex;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: isSelected ? BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).highlightColor.withOpacity(0.5),
            spreadRadius: 4,
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ) : null,
      child: Text(film.title!, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Theme.of(context).primaryColor : null),),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return  Column(
      children: [
        SizedBox(
          height: 100,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.3, 0.4],
                colors: <Color>[
                  Colors.transparent,
                  Theme.of(context).primaryColor,
                ],
                tileMode: TileMode.mirror,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container (
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRandomizeButton(BuildContext context, FilmProvider provider) {
    return FloatingActionButton(
      child: const Icon(Icons.shuffle),
      onPressed:() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleRandomize(provider);
        });
      },
    );
  }

  void _handleRandomize(FilmProvider provider) async {
    setState(() {
      films = randomizeSize(provider.films!.toList());
      selectedFilmIndex = Random().nextInt(films.length - 1);
    });
    if (selectedFilmIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        itemScrollController.scrollTo(
          index: selectedFilmIndex!,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOutSine,
        );
      });
    }
  }
}