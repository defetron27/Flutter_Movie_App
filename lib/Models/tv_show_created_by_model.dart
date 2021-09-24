class TvShowCreatedByModel {
  final int id;
  final String credit_id;
  final String name;
  final int gender;
  final String profile_path;

  TvShowCreatedByModel(
      {this.id, this.credit_id, this.name, this.gender, this.profile_path});

  factory TvShowCreatedByModel.fromJson(Map<String, dynamic> json) {
    return TvShowCreatedByModel(
        id: json['id'],
        credit_id: json['credit_id'],
        name: json['name'],
        gender: json['gender'],
        profile_path: json['profile_path'] == "" || json['profile_path'] == null
            ? json['profile_path']
            : "http://image.tmdb.org/t/p/w780" + json['profile_path']);
  }
}
