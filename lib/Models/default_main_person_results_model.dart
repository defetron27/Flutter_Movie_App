class DefaultMainPersonResultsModel {
  final bool adult;
  final int gender;
  final String name;
  final int id;
  final String known_for;
  final String known_for_department;
  final String profile_path;
  final double popularity;

  DefaultMainPersonResultsModel(
      {this.adult,
      this.gender,
      this.name,
      this.id,
      this.known_for,
      this.known_for_department,
      this.profile_path,
      this.popularity});
      
  factory DefaultMainPersonResultsModel.fromJson(Map<String, dynamic> json) {
    return DefaultMainPersonResultsModel(
        adult: json['adult'],
        gender: json['gender'],
        name: json['name'],
        id: json['id'],
        known_for: json['known_for'].toString(),
        known_for_department: json['known_for_department'],
        profile_path: json['profile_path'] == null
            ? ""
            : "http://image.tmdb.org/t/p/w780" + json['profile_path'],
        popularity: json['popularity']);
  }
}
