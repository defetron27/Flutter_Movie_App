import 'default_images_model.dart';

class TvShowEpisodeImagesModel
{
  final int id;
  final List<DefaultImagesModel> stills;

  TvShowEpisodeImagesModel({this.id, this.stills});

  factory TvShowEpisodeImagesModel.fromJson(Map<String, dynamic> json) {
    var _stills = json['stills'] as List;

    return TvShowEpisodeImagesModel(
        id: json['id'],
        stills:
            _stills.map((i) => DefaultImagesModel.fromJson(i)).toList());
  }
}