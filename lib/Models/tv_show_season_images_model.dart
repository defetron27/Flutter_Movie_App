import 'default_images_model.dart';

class TvShowSeasonImagesModel
{
  final int id;
  final List<DefaultImagesModel> posters;

  TvShowSeasonImagesModel({this.id, this.posters});

  factory TvShowSeasonImagesModel.fromJson(Map<String, dynamic> json) {
    var _posters = json['posters'] as List;

    return TvShowSeasonImagesModel(
        id: json['id'],
        posters:
            _posters.map((i) => DefaultImagesModel.fromJson(i)).toList());
  }
}