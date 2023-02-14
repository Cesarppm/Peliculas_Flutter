
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/search_movie_response.dart';




class MovieProvider extends ChangeNotifier{

      String _apiKey =  'f0e1cbe2128bee8a33b1ed3bcb5d6909';
      String _baseUrl = 'api.themoviedb.org';
      String _lenguaje ='es-ES';

      List<Movie>onDisplayMovies = [];
      List<Movie>popularMovies = [];

      Map<int, List<Cast>> movieCast = {};


      int _popularPage=0;

      final debouncer = Debouncer(
        duration: Duration(milliseconds: 500),
        
        );

      final StreamController<List<Movie>> _suggestionStreamController = new StreamController.broadcast();
      Stream<List<Movie>>get suggestionStream => this._suggestionStreamController.stream;

    MovieProvider(){
      print('MoviesProvier inicializando');

        this.getOnDisplayMovies();
        this.getPopularMovies();

        
    }

    Future<String> _getJsonData( String endpoint, [int page = 1]) async{
      final url = Uri.https( _baseUrl, endpoint, {
        'api_key'  : _apiKey,
        'language' : _lenguaje,
        'page'     : '$page',
        });

          final response = await http.get(url);
          return response.body;

    }
    getOnDisplayMovies() async{
     
      final jsonDta = await _getJsonData('3/movie/now_playing');

      final nosPlayinResponse=  NowPlayingResponse.fromJson(jsonDta);
  
  onDisplayMovies = nosPlayinResponse.results;
  
  notifyListeners();
    
    }
    getPopularMovies() async{
      _popularPage++;
      final jsonDta = await _getJsonData('3/movie/popular', 1);
      final pupularResponse=  PopularResponse.fromJson(jsonDta);
      popularMovies = [...popularMovies  , ...pupularResponse.results];
  
  notifyListeners();
    
    }

    Future<List<Cast>> getMovieCast(int movieId) async{
      // Todo revisar el mapa
      if (movieCast.containsKey(movieId) ) return movieCast[movieId]!;

      print('Pidiendo la infromacion del is');

      final jsonDta = await _getJsonData('3/movie/$movieId/credits');
      final creditsResponse = CreditsResponse.fromJson(jsonDta);

      movieCast[movieId] = creditsResponse.cast;

      return creditsResponse.cast;    
    } 


    Future<List<Movie>> searchMovies(String query) async{
          final url = Uri.https( _baseUrl, '3/search/movie', {
        'api_key'  : _apiKey,
        'language' : _lenguaje,
        'query'    : query,
        });
          final response = await http.get(url);
          final searchResponse = SearchResponse.fromJson(response.body);

          return searchResponse.results;


    }
    void getSuggestionsByQuery (String searchTem){

      debouncer.value = '';
      debouncer.onValue =(value) async {
         // print('Tenemos valor a buscar $value');
         final results = await this.searchMovies(value);
         this._suggestionStreamController.add(results);
      } ;

      final timer = Timer.periodic(Duration (milliseconds: 300), ( _ ){
        debouncer.value = searchTem;
      
      }
      );
      Future.delayed(Duration(milliseconds: 381)).then((_) => timer.cancel());
    }

}