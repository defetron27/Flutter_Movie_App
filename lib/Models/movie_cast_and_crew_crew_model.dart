class MovieCastAndCrewCrewModel {
  final String credit_id;
  final String department;
  final int id;
  final String name;
  final int gender;
  final String job;
  final String profile_path;

  MovieCastAndCrewCrewModel(
      {this.credit_id,
      this.department,
      this.id,
      this.name,
      this.gender,
      this.job,
      this.profile_path});

  factory MovieCastAndCrewCrewModel.fromJson(Map<String, dynamic> json) {
    return MovieCastAndCrewCrewModel(
        credit_id: json['credit_id'],
        department: json['department'],
        id: json['id'],
        name: json['name'],
        gender: json['gender'],
        job: json['job'],
        profile_path: json['profile_path'] == null ? json['profile_path'] : "http://image.tmdb.org/t/p/w780" + json['profile_path']);
  }
}
