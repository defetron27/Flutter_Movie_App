import 'default_images_model.dart';

class TvShowMovieImagesModel {
  final List<DefaultImagesModel> backdrops;
  final int id;
  final List<DefaultImagesModel> posters;

  TvShowMovieImagesModel({this.backdrops, this.id, this.posters});

  factory TvShowMovieImagesModel.fromJson(Map<String, dynamic> json) {
    var _backdrops = json['backdrops'] as List;
    var _posters = json['posters'] as List;

    return TvShowMovieImagesModel(
        backdrops:
            _backdrops.map((i) => DefaultImagesModel.fromJson(i)).toList(),
        id: json['id'],
        posters:
            _posters.map((i) => DefaultImagesModel.fromJson(i)).toList());
  }
}
