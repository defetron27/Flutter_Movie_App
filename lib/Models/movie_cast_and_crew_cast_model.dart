class MovieCastAndCrewCastModel {
  final int cast_id;
  final String character;
  final String credit_id;
  final int gender;
  final int id;
  final String name;
  final int order;
  final String profile_path;

  MovieCastAndCrewCastModel(
      {this.cast_id,
      this.character,
      this.credit_id,
      this.gender,
      this.id,
      this.name,
      this.order,
      this.profile_path});

  factory MovieCastAndCrewCastModel.fromJson(Map<String, dynamic> json) {
    return MovieCastAndCrewCastModel(
      cast_id: json['cast_id'],
      character: json['character'],
      credit_id: json['credit_id'],
      gender: json['gender'],
      id: json['id'],
      name: json['name'],
      order: json['order'],
      profile_path: json['profile_path'] == null
          ? json['profile_path']
          : "http://image.tmdb.org/t/p/w780" + json['profile_path'],
    );
  }
}
