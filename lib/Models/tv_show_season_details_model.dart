import 'tv_show_season_details_episodes_model.dart';

class TvShowSeasonDetailsModel {
  final String season_id;
  final String air_date;
  final List<TvShowSeasonDetailsEpisodesModel> episodes;
  final String name;
  final String overview;
  final int id;
  final String poster_path;
  final int season_number;

  TvShowSeasonDetailsModel(
      {this.season_id,
      this.air_date,
      this.episodes,
      this.name,
      this.overview,
      this.id,
      this.poster_path,
      this.season_number});

  factory TvShowSeasonDetailsModel.fromJson(Map<String, dynamic> json) {
    var _episodes = json['episodes'] as List;

    return TvShowSeasonDetailsModel(
        season_id: json['_id'],
        air_date: json['air_date'],
        episodes: _episodes
            .map((i) => TvShowSeasonDetailsEpisodesModel.fromJson(i))
            .toList(),
        name: json['name'],
        overview: json['overview'],
        id: json['id'],
        poster_path: json['poster_path'] == null
            ? json['poster_path']
            : "http://image.tmdb.org/t/p/w780" + json['poster_path'],
        season_number: json['season_number']);
  }
}
