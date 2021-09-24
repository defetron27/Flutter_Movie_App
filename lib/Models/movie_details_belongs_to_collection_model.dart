class MovieDetailsBelongsToCollectionModel {
  final int id;
  final String name;
  final String poster_path;
  final String backdrop_path;

  MovieDetailsBelongsToCollectionModel(
      {this.id, this.name, this.poster_path, this.backdrop_path});

  factory MovieDetailsBelongsToCollectionModel.fromJson(
      Map<String, dynamic> json) {
    return MovieDetailsBelongsToCollectionModel(
        id: json['id'],
        name: json['name'],
        poster_path: json['poster_path'],
        backdrop_path: json['backdrop_path']);
  }
}
