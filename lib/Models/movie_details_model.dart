import 'movie_details_belongs_to_collection_model.dart';
import 'movie_details_production_countries_model.dart';
import 'movie_details_spoken_languages_model.dart';
import 'tv_show_movie_genres_model.dart';
import 'tv_show_movie_production_companies_model.dart';

class MovieDetailsModel {
  final bool adult;
  final String backdrop_path;
  final MovieDetailsBelongsToCollectionModel belongs_to_collection;
  final int budget;
  final List<TvShowMovieGenresModel> genres;
  final String homepage;
  final int id;
  final String imdb_id;
  final String original_language;
  final String original_title;
  final String overview;
  final double popularity;
  final String poster_path;
  final List<TvShowMovieProductionCompaniesModel> production_companies;
  final List<MovieDetailsProductionCountriesModel> production_countries;
  final String release_date;
  final int revenue;
  final int runtime;
  final List<MovieDetailsSpokenLanguagesModel> spoken_languages;
  final String status;
  final String tagline;
  final String title;
  final bool video;
  final double vote_average;
  final int vote_count;

  MovieDetailsModel(
      {this.adult,
      this.backdrop_path,
      this.belongs_to_collection,
      this.budget,
      this.genres,
      this.homepage,
      this.id,
      this.imdb_id,
      this.original_language,
      this.original_title,
      this.overview,
      this.popularity,
      this.poster_path,
      this.production_companies,
      this.production_countries,
      this.release_date,
      this.revenue,
      this.runtime,
      this.spoken_languages,
      this.status,
      this.tagline,
      this.title,
      this.video,
      this.vote_average,
      this.vote_count});

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    var genresList = json['genres'] as List;
    var productionCompaniesList = json['production_companies'] as List;
    var productionCountriesList = json['production_countries'] as List;
    var spokenLanguagesList = json['spoken_languages'] as List;

    return MovieDetailsModel(
        adult: json['adult'],
        backdrop_path:
            json['backdrop_path'] == "" || json['backdrop_path'] == null
                ? ""
                : "http://image.tmdb.org/t/p/w780" + json['backdrop_path'],
        belongs_to_collection: json['belongs_to_collection'] == null ? json['belongs_to_collection'] : MovieDetailsBelongsToCollectionModel.fromJson(
            json['belongs_to_collection']),
        budget: json['budget'],
        genres: genresList.map((i) => TvShowMovieGenresModel.fromJson(i)).toList(),
        homepage: json['homepage'],
        id: json['id'],
        imdb_id: json['imdb_id'],
        original_language: json['original_language'],
        original_title: json['original_title'],
        overview: json['overview'],
        popularity: json['popularity'],
        poster_path: json['poster_path'] == "" || json['poster_path'] == null
            ? ""
            : "http://image.tmdb.org/t/p/w780" + json['poster_path'],
        production_companies: productionCompaniesList
            .map((i) => TvShowMovieProductionCompaniesModel.fromJson(i))
            .toList(),
        production_countries: productionCountriesList
            .map((i) => MovieDetailsProductionCountriesModel.fromJson(i))
            .toList(),
        release_date: json['release_date'],
        revenue: json['revenue'],
        runtime: json['runtime'],
        spoken_languages: spokenLanguagesList
            .map((i) => MovieDetailsSpokenLanguagesModel.fromJson(i))
            .toList(),
        status: json['status'],
        tagline: json['tagline'],
        title: json['title'],
        video: json['video'],
        vote_average: json['vote_average'].toDouble(),
        vote_count: json['vote_count']);
  }
}
