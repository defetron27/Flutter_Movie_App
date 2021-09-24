class TvShowMovieGenresModel
{
  final int id;
  final String name;

  TvShowMovieGenresModel({this.id, this.name});

  factory TvShowMovieGenresModel.fromJson(Map<String, dynamic> json)
  {
    return TvShowMovieGenresModel(id: json['id'], name: json['name']);
  }
}