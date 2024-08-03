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
  final Iterable<Film>? films;

  const RandomizeScreen({super.key, this.films});

  static String routeName = "/randomizer";

  @override
  State<RandomizeScreen> createState() => _RandomizeScreenState();
}

class _RandomizeScreenState extends State<RandomizeScreen> with SingleTickerProviderStateMixin {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create();
  Iterable<Film> _films = [];
  int? selectedFilmIndex;

  @override
  void initState() {
    super.initState();
    
    setState(() {
      _films = widget.films ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.films == null || widget.films!.isEmpty) {
      Fluttertoast.showToast(msg: "Add films first!");
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(L10nAccessor.get(context, "randomizer_page")),
      ),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            flex: 5,
            child: _buildFilmRandomList(),
          ),
        ],
      ),
      floatingActionButton: _buildRandomizeButton(),
    );
  }

  Widget _buildControls() {
    return Container();
  }

  Widget _buildFilmRandomList() {
    return Stack(
      children: [
        ScrollablePositionedList.builder(
          itemCount: _films.length + 1,
          itemScrollController: itemScrollController,
          scrollOffsetController: scrollOffsetController,
          itemPositionsListener: itemPositionsListener,
          scrollOffsetListener: scrollOffsetListener,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            if (index < _films.length) {
              Film film = _films.elementAt(index);
              return _buildFilmListEntry(index, film);
            } else {
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

  Container _buildFilmListEntry(int index, Film film) {
    bool isSelected = index == selectedFilmIndex;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: isSelected
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).highlightColor.withOpacity(0.75),
                  spreadRadius: 4,
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
            )
          : null,
      child: Text(
        film.title!,
        textAlign: TextAlign.center,
        // style: TextStyle(
        //   color: isSelected ? Theme.of(context).primaryColor : null,
        // ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Column(
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
          child: Container(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRandomizeButton() {
    return FloatingActionButton(
      child: const Icon(Icons.shuffle),
      onPressed: () {
        _handleRandomize();
      },
    );
  }

  void _handleRandomize() {
    setState(() {
      _films = randomizeSize(_films);
      selectedFilmIndex = Random().nextInt(_films.length);
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