import 'person_details_tv_cast_and_crew_cast_model.dart';
import 'person_details_tv_cast_and_crew_crew_model.dart';

class PersonDetailsTvCastAndCrewModel {
  final List<PersonDetailsTvCastAndCrewCastModel> cast;
  final List<PersonDetailsTvCastAndCrewCrewModel> crew;
  final int id;

  PersonDetailsTvCastAndCrewModel({this.cast, this.crew, this.id});

  factory PersonDetailsTvCastAndCrewModel.fromJson(
      Map<String, dynamic> json) {
    var movieTvCast = json['cast'] as List;
    var movieTvCrew = json['crew'] as List;

    return PersonDetailsTvCastAndCrewModel(
        cast: movieTvCast
            .map((i) => PersonDetailsTvCastAndCrewCastModel.fromJson(i))
            .toList(),
        crew: movieTvCrew
            .map((i) => PersonDetailsTvCastAndCrewCrewModel.fromJson(i))
            .toList(),
        id: json['id']);
  }
}
