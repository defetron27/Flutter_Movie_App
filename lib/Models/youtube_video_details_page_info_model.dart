class YoutubeVideoDetailsPageInfoModel
{
  final int totalResults;
  final int resutlsPerPage;

  YoutubeVideoDetailsPageInfoModel({this.totalResults, this.resutlsPerPage});

  factory YoutubeVideoDetailsPageInfoModel.fromJson(Map<String, dynamic> json)
  {
    return YoutubeVideoDetailsPageInfoModel(totalResults: json['totalResults'], resutlsPerPage: json['resutlsPerPage']);
  }
}