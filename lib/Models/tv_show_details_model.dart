import 'tv_show_created_by_model.dart';
import 'tv_show_last_episode_to_air_model.dart';
import 'tv_show_movie_genres_model.dart';
import 'tv_show_movie_production_companies_model.dart';
import 'tv_show_networks_model.dart';
import 'tv_show_next_episode_to_air_model.dart';
import 'tv_show_seasons_model.dart';

class TvShowDetailsModel {
  final String backdrop_path;

  final List<TvShowCreatedByModel> created_by;

  final List<int> episode_run_time;

  final String first_air_date;

  final List<TvShowMovieGenresModel> genres;

  final String homepage;
  final int id;
  final bool in_production;

  final List<String> languages;

  final String last_air_date;

  final TvShowLastEpisodeToAirModel last_episode_to_air;

  final String name;

  final TvShowNextEpisodeToAirModel next_episode_to_air;

  final List<TvShowNetworksModel> networks;

  final int number_of_episodes;
  final int number_of_seasons;

  final List<String> origin_country;

  final String original_language;
  final String original_name;
  final String overview;
  final double popularity;
  final String poster_path;

  final List<TvShowMovieProductionCompaniesModel> production_companies;
  final List<TvShowSeasonsModel> seasons;

  final String status;
  final String type;
  final double vote_average;
  final int vote_count;

  TvShowDetailsModel(
      {this.backdrop_path,
      this.created_by,
      this.episode_run_time,
      this.first_air_date,
      this.genres,
      this.homepage,
      this.id,
      this.in_production,
      this.languages,
      this.last_air_date,
      this.last_episode_to_air,
      this.name,
      this.next_episode_to_air,
      this.networks,
      this.number_of_episodes,
      this.number_of_seasons,
      this.origin_country,
      this.original_language,
      this.original_name,
      this.overview,
      this.popularity,
      this.poster_path,
      this.production_companies,
      this.seasons,
      this.status,
      this.type,
      this.vote_average,
      this.vote_count});

  factory TvShowDetailsModel.fromJson(Map<String, dynamic> json) {
    var createdByList = json['created_by'] as List;
    var genresList = json['genres'] as List;
    var networksList = json['networks'] as List;
    var productionCompaniesList = json['production_companies'] as List;
    var seasonsList = json['seasons'] as List;

    return TvShowDetailsModel(
        backdrop_path:
            json['backdrop_path'] == "" || json['backdrop_path'] == null
                ? json['backdrop_path']
                : "http://image.tmdb.org/t/p/w780" + json['backdrop_path'],
        created_by:
            createdByList.map((i) => TvShowCreatedByModel.fromJson(i)).toList(),
        episode_run_time: List<int>.from(json['episode_run_time']),
        first_air_date: json['first_air_date'],
        genres: genresList.map((i) => TvShowMovieGenresModel.fromJson(i)).toList(),
        homepage: json['homepage'],
        id: json['id'],
        in_production: json['in_production'],
        languages: List<String>.from(json['languages']),
        last_air_date: json['last_air_date'],
        last_episode_to_air:
            TvShowLastEpisodeToAirModel.fromJson(json['last_episode_to_air']),
        name: json['name'],
        next_episode_to_air: json['next_episode_to_air'] == null
            ? json['next_episode_to_air']
            : TvShowNextEpisodeToAirModel.fromJson(json['next_episode_to_air']),
        networks:
            networksList.map((i) => TvShowNetworksModel.fromJson(i)).toList(),
        number_of_episodes: json['number_of_episodes'],
        number_of_seasons: json['number_of_seasons'],
        origin_country: List<String>.from(json['origin_country']),
        original_language: json['original_language'],
        original_name: json['original_name'],
        overview: json['overview'],
        popularity: json['popularity'],
        poster_path: json['poster_path'] == "" || json['poster_path'] == null
            ? ""
            : "http://image.tmdb.org/t/p/w780" + json['poster_path'],
        production_companies: productionCompaniesList
            .map((i) => TvShowMovieProductionCompaniesModel.fromJson(i))
            .toList(),
        seasons:
            seasonsList.map((i) => TvShowSeasonsModel.fromJson(i)).toList(),
        status: json['status'],
        type: json['type'],
        vote_average: json['vote_average'].toDouble(),
        vote_count: json['vote_count']);
  }
}
