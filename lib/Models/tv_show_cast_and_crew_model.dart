import 'tv_show_cast_and_crew_cast_model.dart';
import 'tv_show_cast_and_crew_crew_model.dart';

class TvShowCastAndCrewModel {
  final List<TvShowCastAndCrewCastModel> cast;
  final List<TvShowCastAndCrewCrewModel> crew;
  final int id;

  TvShowCastAndCrewModel({this.cast, this.crew, this.id});

  factory TvShowCastAndCrewModel.fromJson(Map<String, dynamic> json) {
    var tvShowsCast = json['cast'] as List;
    var tvShowsCrew = json['crew'] as List;

    return TvShowCastAndCrewModel(
        cast: tvShowsCast
            .map((i) => TvShowCastAndCrewCastModel.fromJson(i))
            .toList(),
        crew: tvShowsCrew
            .map((i) => TvShowCastAndCrewCrewModel.fromJson(i))
            .toList(),
        id: json['id']);
  }
}
