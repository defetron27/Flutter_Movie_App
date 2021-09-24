class PersonDetailsModel {
  final String birthday;
  final String known_for_department;
  final String deathday;
  final int id;
  final String name;
  final List<String> also_known_as;
  final int gender;
  final String biography;
  final double popularity;
  final String place_of_birth;
  final String profile_path;
  final bool adult;
  final String imdb_id;
  final String homepage;

  PersonDetailsModel(
      {this.birthday,
      this.known_for_department,
      this.deathday,
      this.id,
      this.name,
      this.also_known_as,
      this.gender,
      this.biography,
      this.popularity,
      this.place_of_birth,
      this.profile_path,
      this.adult,
      this.imdb_id,
      this.homepage});

  factory PersonDetailsModel.fromJson(Map<String, dynamic> json) {
    return PersonDetailsModel(
        birthday: json['birthday'],
        known_for_department: json['known_for_department'],
        deathday: json['deathday'],
        id: json['id'],
        name: json['name'],
        also_known_as: List<String>.from(json['also_known_as']),
        gender: json['gender'],
        biography: json['biography'],
        popularity: json['popularity'],
        place_of_birth: json['place_of_birth'],
        profile_path: json['profile_path'] == null ? "" : "http://image.tmdb.org/t/p/w780" + json['profile_path'],
        adult: json['adult'],
        imdb_id: json['imdb_id'],
        homepage: json['homepage']);
  }
}
