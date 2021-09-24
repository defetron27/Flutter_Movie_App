import 'movie_cast_and_crew_cast_model.dart';
import 'movie_cast_and_crew_crew_model.dart';

class MovieCastAndCrewModel {
  final List<MovieCastAndCrewCastModel> cast;
  final List<MovieCastAndCrewCrewModel> crew;
  final int id;

  MovieCastAndCrewModel({this.cast, this.crew, this.id});

  factory MovieCastAndCrewModel.fromJson(Map<String, dynamic> json) {
    var tvShowsCast = json['cast'] as List;
    var tvShowsCrew = json['crew'] as List;

    return MovieCastAndCrewModel(
        cast: tvShowsCast
            .map((i) => MovieCastAndCrewCastModel.fromJson(i))
            .toList(),
        crew: tvShowsCrew
            .map((i) => MovieCastAndCrewCrewModel.fromJson(i))
            .toList(),
        id: json['id']);
  }
}
