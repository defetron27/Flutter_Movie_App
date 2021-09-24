class TvShowSeasonDetailsEpisodeGuestStarsModel {
  final int id;
  final String name;
  final String credit_id;
  final String character;
  final int order;
  final int gender;
  final String profile_path;

  TvShowSeasonDetailsEpisodeGuestStarsModel(
      {this.id,
      this.name,
      this.credit_id,
      this.character,
      this.order,
      this.gender,
      this.profile_path});

  factory TvShowSeasonDetailsEpisodeGuestStarsModel.fromJson(
      Map<String, dynamic> json) {
    return TvShowSeasonDetailsEpisodeGuestStarsModel(
        id: json['id'],
        name: json['name'],
        credit_id: json['credit_id'],
        character: json['character'],
        order: json['order'],
        gender: json['gender'],
        profile_path: json['profile_path'] == null
            ? json['profile_path']
            : "http://image.tmdb.org/t/p/w780" + json['profile_path']);
  }
}
