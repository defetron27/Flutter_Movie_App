class DefaultImagesModel {
  final double aspect_ratio;
  final String file_path;
  final int height;
  final String iso_639_1;
  final double vote_average;
  final int vote_count;
  final int width;

  DefaultImagesModel(
      {this.aspect_ratio,
      this.file_path,
      this.height,
      this.iso_639_1,
      this.vote_average,
      this.vote_count,
      this.width});

  factory DefaultImagesModel.fromJson(Map<String, dynamic> json) {
    return DefaultImagesModel(
        aspect_ratio: json['aspect_ratio'],
        file_path: json['file_path'] == null
            ? json['file_path']
            : "http://image.tmdb.org/t/p/w780" + json['file_path'],
        height: json['height'],
        iso_639_1: json['iso_639_1'],
        vote_average: json['vote_average'].toDouble(),
        vote_count: json['vote_count'],
        width: json['width']);
  }
}
