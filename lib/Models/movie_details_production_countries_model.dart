class MovieDetailsProductionCountriesModel {
  final String iso_3166_1;
  final String name;

  MovieDetailsProductionCountriesModel({this.iso_3166_1, this.name});

  factory MovieDetailsProductionCountriesModel.fromJson(
      Map<String, dynamic> json) {
    return MovieDetailsProductionCountriesModel(
        iso_3166_1: json['iso_3166_1'], name: json['name']);
  }
}
