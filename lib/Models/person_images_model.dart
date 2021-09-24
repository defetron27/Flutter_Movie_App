import 'default_images_model.dart';

class PersonImagesModel {
  final List<DefaultImagesModel> profiles;
  final int id;

  PersonImagesModel({this.profiles, this.id});

  factory PersonImagesModel.fromJson(Map<String, dynamic> json) {
    var _profiles = json['profiles'] as List;
    return PersonImagesModel(
        profiles: _profiles.map((i) => DefaultImagesModel.fromJson(i)).toList(),
        id: json['id']);
  }
}
