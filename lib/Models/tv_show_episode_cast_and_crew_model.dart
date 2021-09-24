import 'tv_show_cast_and_crew_cast_model.dart';
import 'tv_show_cast_and_crew_crew_model.dart';
import 'tv_show_season_details_episode_guest_stars_model.dart';

class TvShowEpisodeCastAndCrewModel {
  final List<TvShowCastAndCrewCastModel> cast;
  final List<TvShowCastAndCrewCrewModel> crew;
  final List<TvShowSeasonDetailsEpisodeGuestStarsModel> guest_stars;
  final int id;

  TvShowEpisodeCastAndCrewModel(
      {this.cast, this.crew, this.guest_stars, this.id});

  factory TvShowEpisodeCastAndCrewModel.fromJson(Map<String, dynamic> json) {
    var tvShowsCast = json['cast'] as List;
    var tvShowsCrew = json['crew'] as List;
    var guestStars = json['guest_stars'] as List;

    return TvShowEpisodeCastAndCrewModel(
        cast: tvShowsCast
            .map((i) => TvShowCastAndCrewCastModel.fromJson(i))
            .toList(),
        crew: tvShowsCrew
            .map((i) => TvShowCastAndCrewCrewModel.fromJson(i))
            .toList(),
        guest_stars: guestStars
            .map((i) => TvShowSeasonDetailsEpisodeGuestStarsModel.fromJson(i))
            .toList(),
        id: json['id']);
  }
}
