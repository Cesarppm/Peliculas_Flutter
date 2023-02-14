import 'package:flutter/material.dart';
import 'package:peliculas/search/search_delegate.dart';
import 'package:peliculas/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/movies_provider.dart';

class HomeScreen extends StatelessWidget {
  


  @override
  Widget build(BuildContext context) {
      final moviesProvider = Provider.of<MovieProvider>(context);
      

      

    return  Scaffold(
      appBar: AppBar(
        title: Text('Peliculas en cines'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search_outlined),
            onPressed: () => showSearch(context: context, delegate: MovieSearchDelegate()), 
            )
            
        ],
        ),
      body: SingleChildScrollView(
        child:  Column(
            children: [

                //Tarjetas principales
                CardSwiper(movies: moviesProvider.onDisplayMovies,),
                //Lista Horizontal de peliculas
                MovieSlider(
                  movies: moviesProvider.popularMovies,
                  title: 'Populares',
                  onNextPage: () => moviesProvider.getPopularMovies(),

                  
                ),
            ],
        ),
      )
    );
  }
}