import 'package:film_randomizer/ui/widgets/bottom_navigation_widget.dart';
import 'package:film_randomizer/ui/widgets/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:film_randomizer/models/film.dart';
import 'package:film_randomizer/providers/film_provider.dart'; 
import 'package:film_randomizer/ui/widgets/film_detail_widget.dart'; 
import 'package:film_randomizer/generated/localization_accessors.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // Accessing the FilmProvider
    final filmProvider = Provider.of<FilmProvider>(context);

    return Scaffold(
      appBar: const MainAppBar(),
      body: filmProvider.films != null
          ? ListView.builder(
              itemCount: filmProvider.films!.length,
              itemBuilder: (context, index) {
                Film film = filmProvider.films!.elementAt(index);
                return FilmDetailWidget(film: film);
              },
            )
          : const Center(child: CircularProgressIndicator()), // Show loading indicator while films are loading
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
