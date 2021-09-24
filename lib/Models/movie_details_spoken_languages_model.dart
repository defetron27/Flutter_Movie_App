class MovieDetailsSpokenLanguagesModel {
  final String iso_639_1;
  final String name;

  MovieDetailsSpokenLanguagesModel({this.iso_639_1, this.name});

  factory MovieDetailsSpokenLanguagesModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailsSpokenLanguagesModel(
        iso_639_1: json['iso_639_1'], name: json['name']);
  }
}
