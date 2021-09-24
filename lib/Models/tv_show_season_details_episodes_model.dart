import 'tv_show_cast_and_crew_crew_model.dart';
import 'tv_show_season_details_episode_guest_stars_model.dart';

class TvShowSeasonDetailsEpisodesModel {
  final String air_date;
  final int episode_number;
  final int id;
  final String name;
  final String overview;
  final String production_code;
  final int season_number;
  final int show_id;
  final String still_path;
  final double vote_average;
  final int vote_count;
  final List<TvShowCastAndCrewCrewModel> crew;
  final List<TvShowSeasonDetailsEpisodeGuestStarsModel> guest_stars;

  TvShowSeasonDetailsEpisodesModel(
      {this.air_date,
      this.episode_number,
      this.id,
      this.name,
      this.overview,
      this.production_code,
      this.season_number,
      this.show_id,
      this.still_path,
      this.vote_average,
      this.vote_count,
      this.crew,
      this.guest_stars});

  factory TvShowSeasonDetailsEpisodesModel.fromJson(Map<String, dynamic> json) {
    var _crew = json['crew'] as List;
    var _guestStars = json['guest_stars'] as List;

    return TvShowSeasonDetailsEpisodesModel(
        air_date: json['air_date'],
        episode_number: json['episode_number'],
        id: json['id'],
        name: json['name'],
        overview: json['overview'],
        production_code: json['production_code'],
        season_number: json['season_number'],
        show_id: json['show_id'],
        still_path: json['still_path'] == null ? json['still_path'] : "http://image.tmdb.org/t/p/w780" + json['still_path'],
        vote_average: json['vote_average'].toDouble(),
        vote_count: json['vote_count'],
        crew: _crew.map((i) => TvShowCastAndCrewCrewModel.fromJson(i)).toList(),
        guest_stars: _guestStars
            .map((i) => TvShowSeasonDetailsEpisodeGuestStarsModel.fromJson(i))
            .toList());
  }
}
