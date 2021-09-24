import 'person_details_movie_cast_and_crew_cast_model.dart';
import 'person_details_movie_cast_and_crew_crew_model.dart';

class PersonDetailsMovieCastAndCrewModel {
  final List<PersonDetailsMovieCastAndCrewCastModel> cast;
  final List<PersonDetailsMovieCastAndCrewCrewModel> crew;
  final int id;

  PersonDetailsMovieCastAndCrewModel({this.cast, this.crew, this.id});

  factory PersonDetailsMovieCastAndCrewModel.fromJson(
      Map<String, dynamic> json) {
    var movieTvCast = json['cast'] as List;
    var movieTvCrew = json['crew'] as List;

    return PersonDetailsMovieCastAndCrewModel(
        cast: movieTvCast
            .map((i) => PersonDetailsMovieCastAndCrewCastModel.fromJson(i))
            .toList(),
        crew: movieTvCrew
            .map((i) => PersonDetailsMovieCastAndCrewCrewModel.fromJson(i))
            .toList(),
        id: json['id']);
  }
}
