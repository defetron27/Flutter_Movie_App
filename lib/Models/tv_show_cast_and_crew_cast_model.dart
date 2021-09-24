class TvShowCastAndCrewCastModel {
  final String character;
  final String credit_id;
  final int id;
  final String name;
  final int gender;
  final String profile_path;
  final int order;

  TvShowCastAndCrewCastModel(
      {this.character,
      this.credit_id,
      this.id,
      this.name,
      this.gender,
      this.profile_path,
      this.order});

  factory TvShowCastAndCrewCastModel.fromJson(Map<String, dynamic> json) {
    return TvShowCastAndCrewCastModel(
        character: json['character'],
        credit_id: json['credit_id'],
        id: json['id'],
        name: json['name'],
        gender: json['gender'],
        profile_path: json['profile_path'] == null ? json['profile_path'] : "http://image.tmdb.org/t/p/w780" + json['profile_path'],
        order: json['order']);
  }
}
