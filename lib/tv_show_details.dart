import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'Models/tv_show_movie_videos_model.dart';
import 'Models/tv_show_movie_videos_results_model.dart';
import 'Utils/LoadingBarIndicator.dart';
import 'zoomable_image_view.dart';
import 'person_details.dart';
import 'youtube_video_player_page.dart';
import 'tv_show_season_details.dart';

import 'Utils/KenBurnsView.dart';
import 'Utils/GetLanguageName.dart';
import 'Utils/NewPageTransition.dart';

import 'Models/tv_show_created_by_model.dart';
import 'Models/tv_show_last_episode_to_air_model.dart';
import 'Models/tv_show_networks_model.dart';
import 'Models/tv_show_next_episode_to_air_model.dart';
import 'Models/tv_show_movie_production_companies_model.dart';
import 'Models/tv_show_seasons_model.dart';
import 'Models/tv_show_movie_genres_model.dart';
import 'Models/tv_show_details_model.dart';
import 'Models/tv_show_movie_images_model.dart';
import 'Models/youtube_video_details_items_content_details_model.dart';
import 'Models/youtube_video_details_model.dart';
import 'Models/tv_show_cast_and_crew_model.dart';
import 'Models/tv_show_cast_and_crew_cast_model.dart';
import 'Models/tv_show_cast_and_crew_crew_model.dart';

class TvShowDetails extends StatefulWidget {
  final int tvShowId;

  TvShowDetails({Key key, @required this.tvShowId}) : super(key: key);

  @override
  _TvShowDetailsState createState() => _TvShowDetailsState(tvShowId);
}

class CirclePainter extends CustomPainter {
  final Color color;

  CirclePainter({@required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = color;

    var path = Path();

    double width = size.width;

    path.lineTo(0, (width - 300.0) / 2);

    path.relativeCubicTo(0, 0, 0, 0, width, 0);
    path.lineTo(width, 0);
    path.addRRect(
      RRect.fromRectAndCorners(
        Rect.fromPoints(
          Offset(0, 0),
          Offset(width, (width - 300.0) / 2),
        ),
        bottomLeft: Radius.circular(50.0),
        bottomRight: Radius.circular(50.0),
      ),
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _TvShowDetailsState extends State<TvShowDetails>
    with TickerProviderStateMixin {
  MediaQueryData mediaQueryData;

  double screenWidth;
  double screenHeight;

  int tvShowId;

  TvShowDetailsModel tvShowDetailsModel;
  TvShowLastEpisodeToAirModel tvShowLastEpisodeToAirModel;
  TvShowNextEpisodeToAirModel tvShowNextEpisodeToAirModel;
  List<TvShowCreatedByModel> tvShowCreatedByList;
  List<TvShowNetworksModel> tvShowNetworksList;
  List<TvShowMovieProductionCompaniesModel> tvShowProductionCompaniesList;
  List<TvShowSeasonsModel> tvShowSeasonsList;
  TvShowMovieVideosModel tvShowVideosModel;
  List<TvShowMovieVideosResultsModel> tvShowVideosResultsList;

  TvShowMovieImagesModel tvShowImagesModel;
  var tvShowImagesBackdropsList = List<String>();
  var tvShowImagesPostersList = List<String>();

  List<TvShowCastAndCrewCastModel> tvShowCastAndCrewCastList;
  List<TvShowCastAndCrewCrewModel> tvShowCastAndCrewCrewList;

  var tvShowYoutubeVideosResultsList = List<TvShowMovieVideosResultsModel>();
  var youtubeVideosDurationsList = List<String>();
  var tvShowDetailsList = Map<String, String>();
  var tvShowLastEdpisodeDetailsList = Map<String, String>();
  var tvShowNextEdpisodeDetailsList = Map<String, String>();

  StringBuffer languageStringBuffer = StringBuffer();
  StringBuffer countryStringBuffer = StringBuffer();
  StringBuffer genresStringBuffer = StringBuffer();

  String dummyImageUrl =
      'https://davidbalyeat.com/wp-content/uploads/manhattan-bridge-brooklyn-manhattan-new-york-city-sunset.jpg';

  _TvShowDetailsState(int tvShowId) {
    this.tvShowId = tvShowId;
  }

  Future<String> fetchTvShowDetails() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$tvShowId?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        tvShowDetailsModel =
            TvShowDetailsModel.fromJson(json.decode(response.body));
        tvShowLastEpisodeToAirModel = tvShowDetailsModel.last_episode_to_air;
        tvShowNextEpisodeToAirModel = tvShowDetailsModel.next_episode_to_air;
        tvShowCreatedByList = tvShowDetailsModel.created_by;
        tvShowNetworksList = tvShowDetailsModel.networks;
        tvShowProductionCompaniesList = tvShowDetailsModel.production_companies;
        tvShowSeasonsList = tvShowDetailsModel.seasons;

        var translsatedLanguages = tvShowDetailsModel.languages;
        var originCountry = tvShowDetailsModel.origin_country;
        List<TvShowMovieGenresModel> genres = tvShowDetailsModel.genres;

        for (int i = 0; i < translsatedLanguages.length; i++) {
          if (tvShowDetailsModel.original_language != translsatedLanguages[i]) {
            if (i == tvShowDetailsModel.languages.length - 1) {
              languageStringBuffer.write(GetLanguage()
                  .getLanguageName(translsatedLanguages[i])['name']);
            } else {
              languageStringBuffer.write(GetLanguage()
                  .getLanguageName(translsatedLanguages[i])['name']);
              languageStringBuffer.write(",");
            }
          }
        }

        for (int i = 0; i < originCountry.length; i++) {
          if (i == tvShowDetailsModel.origin_country.length - 1) {
            countryStringBuffer.write(originCountry[i]);
          } else {
            countryStringBuffer.write(originCountry[i]);
            countryStringBuffer.write(",");
          }
        }

        for (int i = 0; i < genres.length; i++) {
          if (i == tvShowDetailsModel.genres.length - 1) {
            genresStringBuffer.write(genres[i].name);
          } else {
            genresStringBuffer.write(genres[i].name);
            genresStringBuffer.write(",");
          }
        }

        if (tvShowDetailsModel.episode_run_time[0] != null) {
          tvShowDetailsList["Runtime"] = " : " +
              tvShowDetailsModel.episode_run_time[0].toString() +
              " min";
        }

        if (tvShowDetailsModel.original_name != "" &&
            tvShowDetailsModel.original_name != null) {
          tvShowDetailsList["Original Title"] =
              " : " + tvShowDetailsModel.original_name;
        }

        if (tvShowDetailsModel.origin_country.length > 0 &&
            tvShowDetailsModel.origin_country != null) {
          tvShowDetailsList["Original Country"] =
              " : " + countryStringBuffer.toString();
        }

        if (tvShowDetailsModel.original_language != "" &&
            tvShowDetailsModel.original_language != null) {
          tvShowDetailsList["Original Language"] = " : " +
              GetLanguage().getLanguageName(
                  tvShowDetailsModel.original_language)['name'];
        }

        if (tvShowDetailsModel.languages.length > 0 &&
            tvShowDetailsModel.languages != null) {
          tvShowDetailsList["Translated Languages"] =
              " : " + languageStringBuffer.toString();
        }

        if (tvShowDetailsModel.genres.length > 0 &&
            tvShowDetailsModel.genres != null) {
          tvShowDetailsList["Genres"] = " : " + genresStringBuffer.toString();
        }

        if (tvShowDetailsModel.status != "" &&
            tvShowDetailsModel.status != null) {
          tvShowDetailsList["Status"] = " : " + tvShowDetailsModel.status;
        }

        if (tvShowDetailsModel.type != "" && tvShowDetailsModel.type != null) {
          tvShowDetailsList["Type"] = " : " + tvShowDetailsModel.type;
        }
        if (tvShowDetailsModel.number_of_seasons != null) {
          tvShowDetailsList["Number of Seasons"] =
              " : " + tvShowDetailsModel.number_of_seasons.toString();
        }
        if (tvShowDetailsModel.number_of_episodes != null) {
          tvShowDetailsList["Number of Episodes"] =
              " : " + tvShowDetailsModel.number_of_episodes.toString();
        }
        if (tvShowDetailsModel.first_air_date != "" &&
            tvShowDetailsModel.first_air_date != null) {
          tvShowDetailsList["First Episode Released Date"] =
              " : " + tvShowDetailsModel.first_air_date;
        }
        if (tvShowDetailsModel.last_air_date != "" &&
            tvShowDetailsModel.last_air_date != null) {
          tvShowDetailsList["Last Episode Released Date"] =
              " : " + tvShowDetailsModel.last_air_date;
        }
        if (tvShowDetailsModel.next_episode_to_air != null) {
          tvShowDetailsList["Next Episode Release Date"] =
              " : " + tvShowDetailsModel.next_episode_to_air.air_date;
          if (tvShowNextEpisodeToAirModel.vote_average != null) {
            tvShowLastEdpisodeDetailsList["Average Rating"] = " : " +
                tvShowNextEpisodeToAirModel.vote_average.toString() +
                "/10";
          }
          if (tvShowNextEpisodeToAirModel.air_date != "" &&
              tvShowNextEpisodeToAirModel.air_date != null) {
            tvShowLastEdpisodeDetailsList["Release Date"] =
                " : " + tvShowNextEpisodeToAirModel.air_date;
          }
          if (tvShowNextEpisodeToAirModel.season_number != null) {
            tvShowLastEdpisodeDetailsList["Season"] =
                " : " + tvShowNextEpisodeToAirModel.season_number.toString();
          }
          if (tvShowNextEpisodeToAirModel.episode_number != null) {
            tvShowLastEdpisodeDetailsList["Episode"] =
                " : " + tvShowNextEpisodeToAirModel.episode_number.toString();
          }
        }
        if (tvShowDetailsModel.last_episode_to_air != null) {
          if (tvShowLastEpisodeToAirModel.vote_average != null) {
            tvShowLastEdpisodeDetailsList["Average Rating"] = " : " +
                tvShowLastEpisodeToAirModel.vote_average.toString() +
                "/10";
          }
          if (tvShowLastEpisodeToAirModel.air_date != "" &&
              tvShowLastEpisodeToAirModel.air_date != null) {
            tvShowLastEdpisodeDetailsList["Release Date"] =
                " : " + tvShowLastEpisodeToAirModel.air_date;
          }
          if (tvShowLastEpisodeToAirModel.season_number != null) {
            tvShowLastEdpisodeDetailsList["Season"] =
                " : " + tvShowLastEpisodeToAirModel.season_number.toString();
          }
          if (tvShowLastEpisodeToAirModel.episode_number != null) {
            tvShowLastEdpisodeDetailsList["Episode"] =
                " : " + tvShowLastEpisodeToAirModel.episode_number.toString();
          }
        }
      });
    }

    return "success";
  }

  Future fetchTvShowCastAndCrew() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$tvShowId/credits?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        TvShowCastAndCrewModel tvShowCastAndCrewModel =
            TvShowCastAndCrewModel.fromJson(json.decode(response.body));
        tvShowCastAndCrewCastList = tvShowCastAndCrewModel.cast;
        tvShowCastAndCrewCrewList = tvShowCastAndCrewModel.crew;
      });
    }
  }

  Future fetchTvShowVideos() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$tvShowId/videos?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        tvShowVideosModel =
            TvShowMovieVideosModel.fromJson(json.decode(response.body));
        tvShowVideosResultsList = tvShowVideosModel.results;

        for (var i in tvShowVideosResultsList) {
          if (i.site == "YouTube") {
            tvShowYoutubeVideosResultsList.add(i);
          }
        }
        if (tvShowYoutubeVideosResultsList != null &&
            tvShowYoutubeVideosResultsList.length > 0) {
          fetchYoutubeVideoDetails(tvShowYoutubeVideosResultsList);
        }
      });
    }
  }

  Future fetchYoutubeVideoDetails(
      List<TvShowMovieVideosResultsModel>
          tvShowYoutubeVideosResultsList) async {
    var durationsList = List<String>();

    for (var youtubeVideos in tvShowYoutubeVideosResultsList) {
      String videoId = youtubeVideos.key;

      final response = await http.get(
          Uri.encodeFull(
              'https://www.googleapis.com/youtube/v3/videos?id=$videoId&part=contentDetails&key=AIzaSyCXqUoaOT7iCNxSHkPSi-Q2l1F18ii0eG8'),
          headers: {"Accept": "application/json"});

      YoutubeVideoDetailsModel youtubeVideoDetailsModel =
          YoutubeVideoDetailsModel.fromJson(json.decode(response.body));

      YoutubeVideoDetailsItemsContentDetailsModel detailsModel =
          youtubeVideoDetailsModel.items[0].contentDetails;

      String detailsDuration = detailsModel.duration.toLowerCase().substring(2);

      var hours = detailsDuration.split("h");

      var minutes =
          hours.length == 2 ? hours[1].split("m") : hours[0].split("m");

      var seconds =
          minutes.length == 2 ? minutes[1].split("s") : minutes[0].split("s");

      String durationHours = hours.length == 2 ? hours[0] + ":" : "";

      String durationMinutes = minutes.length == 2 ? minutes[0] + ":" : "";

      durationsList.add(durationHours + durationMinutes + seconds[0]);
    }

    setState(() {
      youtubeVideosDurationsList = durationsList;
    });
  }

  Future fetchTvShowImages() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/$tvShowId/images?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        tvShowImagesModel =
            TvShowMovieImagesModel.fromJson(json.decode(response.body));
        tvShowImagesBackdropsList =
            tvShowImagesModel.backdrops.map((i) => i.file_path).toList();
        tvShowImagesPostersList =
            tvShowImagesModel.posters.map((i) => i.file_path).toList();
      });
    }
  }

  ScrollController _controller;

  double topRadius = 0.0;
  double bottomRadius = 100.0;

  Color curveColor = Colors.grey[200];
  Color bgColor = Colors.transparent;
  Color posterShadow = Colors.white;

  double posterSize = 120.0;

  PageController createdByPageController = PageController();
  double createdByCurrentPage = 0.0;

  PageController castPageController = PageController();
  double castCurrentPage = 0.0;

  PageController crewPageController = PageController();
  double crewCurrentPage = 0.0;

  PageController networksPageController = PageController();
  double networksCurrentPage = 0.0;

  PageController productionCompaniesPageController = PageController();
  double productionCompaniesCurrentPage = 0.0;

  PageController seasonsPageController = PageController();
  double seasonsCurrentPage = 0.0;

  PageController videosPageController = PageController();
  double videosCurrentPage = 0.0;

  PageController backdropsPageController = PageController();
  double backdropsCurrentPage = 0.0;

  PageController postersPageController = PageController();
  double postersCurrentPage = 0.0;

  @override
  void initState() {
    super.initState();

    this.fetchTvShowDetails();
    this.fetchTvShowCastAndCrew();
    // this.fetchTvShowVideos();
    this.fetchTvShowImages();

    _controller = ScrollController()..addListener(_scrollListener);

    createdByPageController.addListener(() {
      setState(() {
        createdByCurrentPage = createdByPageController.page;
      });
    });

    castPageController.addListener(() {
      setState(() {
        castCurrentPage = castPageController.page;
      });
    });

    crewPageController.addListener(() {
      setState(() {
        crewCurrentPage = crewPageController.page;
      });
    });

    networksPageController.addListener(() {
      setState(() {
        networksCurrentPage = networksPageController.page;
      });
    });

    productionCompaniesPageController.addListener(() {
      setState(() {
        productionCompaniesCurrentPage = productionCompaniesPageController.page;
      });
    });

    seasonsPageController.addListener(() {
      setState(() {
        seasonsCurrentPage = seasonsPageController.page;
      });
    });

    videosPageController.addListener(() {
      setState(() {
        videosCurrentPage = videosPageController.page;
      });
    });

    backdropsPageController.addListener(() {
      setState(() {
        backdropsCurrentPage = backdropsPageController.page;
      });
    });

    postersPageController.addListener(() {
      setState(() {
        postersCurrentPage = postersPageController.page;
      });
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (this.mounted) {
      if (_controller.hasClients) {
        if (_controller.offset >= 150) {
          setState(() {
            topRadius = 100.0;
            bottomRadius = 0.0;

            curveColor = Colors.transparent;
            bgColor = Colors.grey[200];
            posterShadow = Colors.white;
          });
        } else {
          setState(() {
            topRadius = 0.0;
            bottomRadius = 100.0;

            curveColor = Colors.grey[200];
            bgColor = Colors.transparent;
            posterShadow = Colors.white;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    var _colors = List<Color>();

    _colors.add(Colors.green);
    _colors.add(Colors.blue);
    _colors.add(Colors.yellow);
    _colors.add(Colors.purple);
    _colors.add(Colors.deepOrange);

    return Scaffold(
      backgroundColor: Colors.white,
      primary: false,
      body: tvShowDetailsModel == null
          ? Container(
              color: Colors.white,
              child: Center(
                child: LoadingBarIndicator(
                  numberOfBars: 5,
                  colors: _colors,
                  barSpacing: 5.0,
                  beginTweenValue: 20.0,
                  endTweenValue: 30.0,
                ),
              ),
            )
          : CustomScrollView(
              controller: _controller,
              slivers: <Widget>[
                SliverAppBar(
                  primary: false,
                  leading: Container(
                    margin: EdgeInsets.only(
                      top: 25.0,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(180.0),
                    child: SizedBox.fromSize(
                      size: Size.fromHeight(136.0),
                      child: LayoutBuilder(
                        builder: (context, constraint) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox.fromSize(
                              size: Size.fromHeight(30.0),
                              child: CustomPaint(
                                painter: CirclePainter(
                                  color: curveColor,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(topRadius),
                                      topRight: Radius.circular(topRadius),
                                      bottomLeft: Radius.circular(bottomRadius),
                                      bottomRight:
                                          Radius.circular(bottomRadius),
                                    ),
                                    color: bgColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  backgroundColor: Colors.green[300],
                  elevation: 0.0,
                  expandedHeight: 400.0,
                  floating: false,
                  pinned: true,
                  snap: false,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          tvShowDetailsModel.poster_path == ""
                              ? Container(
                                  child: Icon(
                                    Icons.live_tv,
                                    color: Colors.grey[100],
                                    size: 80,
                                  ),
                                )
                              : AnimatedContainer(
                                  width: posterSize,
                                  height: posterSize,
                                  margin: EdgeInsets.only(bottom: 5.0),
                                  duration: Duration(
                                    milliseconds: 200,
                                  ),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: posterShadow,
                                        blurRadius: 20.0,
                                      ),
                                    ],
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        tvShowDetailsModel.poster_path,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                          tvShowDetailsModel.name == "" ||
                                  tvShowDetailsModel.name == null
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.only(
                                      left: 75.0,
                                      right: 75.0,
                                      top: 7.0,
                                      bottom: 25.0),
                                  child: Text(
                                    tvShowDetailsModel.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "ConcertOne-Regular",
                                        color: Colors.white),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    background: tvShowDetailsModel.backdrop_path == null ||
                            tvShowDetailsModel.backdrop_path == ""
                        ? Container(
                            color: Colors.grey,
                          )
                        : KenBurns(
                            url: tvShowDetailsModel.backdrop_path,
                            duration: 5000,
                            width: 800.0,
                            height: 800.0,
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      tvShowDetailsModel.vote_average == null
                          ? Container()
                          : Container(
                              color: Colors.grey[200],
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: screenWidth,
                                    margin: EdgeInsets.only(
                                        top: 20.0,
                                        left: 10.0,
                                        right: 10.0,
                                        bottom: 10.0),
                                    child: Text(
                                      "Average Rating : " +
                                          tvShowDetailsModel.vote_average
                                              .toString() +
                                          "/10",
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontFamily: "ConcertOne-Regular",
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 0.5,
                                    margin: EdgeInsets.only(top: 10.0),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(color: Colors.black),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Container(
                        color: Colors.grey[200],
                        height: 90.0,
                        padding: EdgeInsets.all(5.0),
                        width: screenWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  screenWidth.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "ConcertOne-Regular",
                                      color: Colors.black),
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.thumb_up,
                                    color: Colors.grey[800],
                                  ),
                                )
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "1347",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "ConcertOne-Regular",
                                      color: Colors.black),
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.thumb_down,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "1347",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "ConcertOne-Regular",
                                      color: Colors.black),
                                ),
                                GestureDetector(
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.grey[200],
                        width: screenWidth,
                        height: 60,
                        padding: EdgeInsets.only(
                          bottom: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              child: Text(
                                "Rate Movie",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black,
                                      spreadRadius: 1.0,
                                      blurRadius: 0.5,
                                    ),
                                  ],
                                  decoration: TextDecoration.underline,
                                  letterSpacing: 1.0,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                ),
                              ),
                              onTap: () {},
                            ),
                            Text(
                              "4.8",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: "ConcertOne-Regular",
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1.0,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return Container(
                      margin: EdgeInsets.only(
                        left: 15.0,
                        right: 15.0,
                        top: 15.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Text(
                              tvShowDetailsList.entries.toList()[index].key,
                              textAlign: TextAlign.start,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                fontFamily: "CantoraOne-Regular",
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                tvShowDetailsList.entries.toList()[index].value,
                                textAlign: TextAlign.start,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: tvShowDetailsList.length),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        height: 0.5,
                        margin: EdgeInsets.only(top: 20.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.black),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                          top: 15.0,
                        ),
                        child: Text(
                          "Overview",
                          textAlign: TextAlign.start,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w100,
                            fontSize: 16,
                            fontFamily: "ConcertOne-Regular",
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          bottom: 10.0,
                        ),
                        padding: EdgeInsets.all(10.0),
                        child: Text(
                          tvShowDetailsModel.overview,
                          textAlign: TextAlign.start,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        height: 0.5,
                        margin: EdgeInsets.only(bottom: 0.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: tvShowLastEpisodeToAirModel == null
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Last Episode",
                                textAlign: TextAlign.start,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                                bottom: 20.0,
                                top: 15.0,
                              ),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 3.0,
                                    spreadRadius: 0.0,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  tvShowLastEpisodeToAirModel.still_path ==
                                              null ||
                                          tvShowLastEpisodeToAirModel
                                                  .still_path ==
                                              ""
                                      ? Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.live_tv,
                                              color: Colors.grey[100],
                                              size: 80,
                                            ),
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.circular(10.0),
                                          ),
                                          child: Image.network(
                                            tvShowLastEpisodeToAirModel
                                                .still_path,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0)),
                                      child: ExpansionTile(
                                        backgroundColor: Colors.white,
                                        title:
                                            tvShowLastEpisodeToAirModel.name ==
                                                        "" ||
                                                    tvShowLastEpisodeToAirModel
                                                            .name ==
                                                        null
                                                ? Text("")
                                                : Text(
                                                    tvShowLastEpisodeToAirModel
                                                        .name,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontFamily:
                                                            "ConcertOne-Regular",
                                                        color: Colors.black),
                                                  ),
                                        children: [
                                          Container(
                                            color: Colors.grey[200],
                                            padding: EdgeInsets.only(
                                                left: 10.0,
                                                right: 10.0,
                                                bottom: 10.0),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              itemCount:
                                                  tvShowLastEdpisodeDetailsList
                                                      .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Container(
                                                  margin: EdgeInsets.all(5.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text(
                                                          tvShowLastEdpisodeDetailsList
                                                              .entries
                                                              .toList()[index]
                                                              .key,
                                                          textAlign:
                                                              TextAlign.start,
                                                          textDirection:
                                                              TextDirection.ltr,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 15,
                                                            fontFamily:
                                                                "CantoraOne-Regular",
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          tvShowLastEdpisodeDetailsList
                                                              .entries
                                                              .toList()[index]
                                                              .value,
                                                          textAlign:
                                                              TextAlign.start,
                                                          textDirection:
                                                              TextDirection.ltr,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            height: 0.5,
                                            margin:
                                                EdgeInsets.only(bottom: 10.0),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(color: Colors.black),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color: Colors.white,
                                            padding: EdgeInsets.only(
                                                left: 15.0,
                                                right: 10.0,
                                                bottom: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  child: Text(
                                                    "Overview",
                                                    textAlign: TextAlign.start,
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w100,
                                                      fontSize: 16,
                                                      fontFamily:
                                                          "ConcertOne-Regular",
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Text(
                                                    tvShowLastEpisodeToAirModel
                                                        .overview,
                                                    textAlign: TextAlign.start,
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: tvShowNextEpisodeToAirModel == null
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Next Episode",
                                textAlign: TextAlign.start,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                left: 20.0,
                                right: 20.0,
                                bottom: 20.0,
                                top: 15.0,
                              ),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 3.0,
                                    spreadRadius: 0.0,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  tvShowNextEpisodeToAirModel.still_path ==
                                              null ||
                                          tvShowNextEpisodeToAirModel
                                                  .still_path ==
                                              ""
                                      ? Container(
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0),
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.live_tv,
                                              color: Colors.grey[100],
                                              size: 80,
                                            ),
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.circular(10.0),
                                          ),
                                          child: Image.network(
                                            tvShowNextEpisodeToAirModel
                                                .still_path,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0)),
                                      child: ExpansionTile(
                                        backgroundColor: Colors.white,
                                        title:
                                            tvShowNextEpisodeToAirModel.name ==
                                                        "" ||
                                                    tvShowNextEpisodeToAirModel
                                                            .name ==
                                                        null
                                                ? Text("")
                                                : Text(
                                                    tvShowNextEpisodeToAirModel
                                                        .name,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontFamily:
                                                            "ConcertOne-Regular",
                                                        color: Colors.black),
                                                  ),
                                        children: [
                                          Container(
                                            color: Colors.grey[200],
                                            padding: EdgeInsets.only(
                                                left: 10.0,
                                                right: 10.0,
                                                bottom: 10.0),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              itemCount:
                                                  tvShowLastEdpisodeDetailsList
                                                      .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Container(
                                                  margin: EdgeInsets.all(5.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text(
                                                          tvShowLastEdpisodeDetailsList
                                                              .entries
                                                              .toList()[index]
                                                              .key,
                                                          textAlign:
                                                              TextAlign.start,
                                                          textDirection:
                                                              TextDirection.ltr,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 15,
                                                            fontFamily:
                                                                "CantoraOne-Regular",
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          tvShowLastEdpisodeDetailsList
                                                              .entries
                                                              .toList()[index]
                                                              .value,
                                                          textAlign:
                                                              TextAlign.start,
                                                          textDirection:
                                                              TextDirection.ltr,
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          Container(
                                            height: 0.5,
                                            margin:
                                                EdgeInsets.only(bottom: 10.0),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(color: Colors.black),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            color: Colors.white,
                                            padding: EdgeInsets.only(
                                                left: 15.0,
                                                right: 10.0,
                                                bottom: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  child: Text(
                                                    "Overview",
                                                    textAlign: TextAlign.start,
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w100,
                                                      fontSize: 16,
                                                      fontFamily:
                                                          "ConcertOne-Regular",
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Text(
                                                    tvShowNextEpisodeToAirModel
                                                        .overview,
                                                    textAlign: TextAlign.start,
                                                    textDirection:
                                                        TextDirection.ltr,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: tvShowCreatedByList == null ||
                          tvShowCreatedByList.length == 0
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Created By",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 220.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                physics: BouncingScrollPhysics(),
                                controller: createdByPageController,
                                itemCount: tvShowCreatedByList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == createdByCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 -
                                          (createdByCurrentPage - index)),
                                      child: buildCreatedByListItems(
                                          tvShowCreatedByList[index]),
                                    );
                                  } else if (index ==
                                      createdByCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 +
                                          (createdByCurrentPage - index)),
                                      child: buildCreatedByListItems(
                                          tvShowCreatedByList[index]),
                                    );
                                  } else {
                                    return buildCreatedByListItems(
                                        tvShowCreatedByList[index]);
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: tvShowCastAndCrewCastList == null ||
                          tvShowCastAndCrewCastList.length == 0
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Show Cast",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 330.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: castPageController,
                                itemCount: tvShowCastAndCrewCastList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == castCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 - (castCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowCastAndCrewCastList[index]
                                            .profile_path,
                                        tvShowCastAndCrewCastList[index].name,
                                        tvShowCastAndCrewCastList[index]
                                            .character,
                                        tvShowCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowCastAndCrewCastList[index].id,
                                        "cast",
                                      ),
                                    );
                                  } else if (index ==
                                      castCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 + (castCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowCastAndCrewCastList[index]
                                            .profile_path,
                                        tvShowCastAndCrewCastList[index].name,
                                        tvShowCastAndCrewCastList[index]
                                            .character,
                                        tvShowCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowCastAndCrewCastList[index].id,
                                        "cast",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      tvShowCastAndCrewCastList[index]
                                          .profile_path,
                                      tvShowCastAndCrewCastList[index].name,
                                      tvShowCastAndCrewCastList[index]
                                          .character,
                                      tvShowCastAndCrewCastList[index]
                                          .credit_id
                                          .toString(),
                                      tvShowCastAndCrewCastList[index].id,
                                      "cast",
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: tvShowCastAndCrewCrewList == null ||
                          tvShowCastAndCrewCrewList.length == 0
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Show Crew",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 330.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: crewPageController,
                                itemCount: tvShowCastAndCrewCrewList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == crewCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 - (crewCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowCastAndCrewCrewList[index]
                                            .profile_path,
                                        tvShowCastAndCrewCrewList[index].name,
                                        tvShowCastAndCrewCrewList[index]
                                            .department,
                                        tvShowCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowCastAndCrewCrewList[index].id,
                                        "crew",
                                      ),
                                    );
                                  } else if (index ==
                                      crewCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 + (crewCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowCastAndCrewCrewList[index]
                                            .profile_path,
                                        tvShowCastAndCrewCrewList[index].name,
                                        tvShowCastAndCrewCrewList[index]
                                            .department,
                                        tvShowCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        tvShowCastAndCrewCrewList[index].id,
                                        "crew",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      tvShowCastAndCrewCrewList[index]
                                          .profile_path,
                                      tvShowCastAndCrewCrewList[index].name,
                                      tvShowCastAndCrewCrewList[index]
                                          .department,
                                      tvShowCastAndCrewCrewList[index]
                                          .credit_id
                                          .toString(),
                                      tvShowCastAndCrewCrewList[index].id,
                                      "crew",
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: tvShowNetworksList == null ||
                          tvShowNetworksList.length == 0
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Networks",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 330.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: networksPageController,
                                itemCount: tvShowNetworksList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == networksCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 - (networksCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowNetworksList[index].logo_path,
                                        tvShowNetworksList[index].name,
                                        tvShowNetworksList[index]
                                            .origin_country,
                                        tvShowNetworksList[index].id.toString(),
                                        tvShowNetworksList[index].id,
                                        "networks",
                                      ),
                                    );
                                  } else if (index ==
                                      networksCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 + (networksCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowNetworksList[index].logo_path,
                                        tvShowNetworksList[index].name,
                                        tvShowNetworksList[index]
                                            .origin_country,
                                        tvShowNetworksList[index].id.toString(),
                                        tvShowNetworksList[index].id,
                                        "networks",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      tvShowNetworksList[index].logo_path,
                                      tvShowNetworksList[index].name,
                                      tvShowNetworksList[index].origin_country,
                                      tvShowNetworksList[index].id.toString(),
                                      tvShowNetworksList[index].id,
                                      "networks",
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: tvShowProductionCompaniesList == null ||
                          tvShowProductionCompaniesList.length == 0
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Production Companies",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 330.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: productionCompaniesPageController,
                                itemCount: tvShowProductionCompaniesList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index ==
                                      productionCompaniesCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 -
                                          (productionCompaniesCurrentPage -
                                              index)),
                                      child: buildThreeLayerListItems(
                                        tvShowProductionCompaniesList[index]
                                            .logo_path,
                                        tvShowProductionCompaniesList[index]
                                            .name,
                                        tvShowProductionCompaniesList[index]
                                            .origin_country,
                                        tvShowProductionCompaniesList[index]
                                            .id
                                            .toString(),
                                        tvShowProductionCompaniesList[index].id,
                                        "productionCompanies",
                                      ),
                                    );
                                  } else if (index ==
                                      productionCompaniesCurrentPage.floor() +
                                          1) {
                                    return Transform.scale(
                                      scale: (1.0 +
                                          (productionCompaniesCurrentPage -
                                              index)),
                                      child: buildThreeLayerListItems(
                                        tvShowProductionCompaniesList[index]
                                            .logo_path,
                                        tvShowProductionCompaniesList[index]
                                            .name,
                                        tvShowProductionCompaniesList[index]
                                            .origin_country,
                                        tvShowProductionCompaniesList[index]
                                            .id
                                            .toString(),
                                        tvShowProductionCompaniesList[index].id,
                                        "productionCompanies",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      tvShowProductionCompaniesList[index]
                                          .logo_path,
                                      tvShowProductionCompaniesList[index].name,
                                      tvShowProductionCompaniesList[index]
                                          .origin_country,
                                      tvShowProductionCompaniesList[index]
                                          .id
                                          .toString(),
                                      tvShowProductionCompaniesList[index].id,
                                      "productionCompanies",
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        margin: EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                          top: 15.0,
                        ),
                        child: Text(
                          "Videos",
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w100,
                            fontSize: 16,
                            fontFamily: "ConcertOne-Regular",
                          ),
                        ),
                      ),
                      Container(
                        height: 1 / (16 / 9) * screenWidth,
                        margin: EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          controller: videosPageController,
                          itemCount: tvShowYoutubeVideosResultsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (tvShowYoutubeVideosResultsList[index].key ==
                                    null ||
                                youtubeVideosDurationsList.length <= 0 ||
                                youtubeVideosDurationsList[index] == null) {
                              return Container();
                            } else {
                              String key =
                                  tvShowYoutubeVideosResultsList[index].key;

                              String duration =
                                  youtubeVideosDurationsList[index];

                              if (index == videosCurrentPage.floor()) {
                                return Transform.scale(
                                  scale: (1.0 - (videosCurrentPage - index)),
                                  child: buildVideosListItems(
                                    tvShowYoutubeVideosResultsList[index],
                                    key,
                                    duration,
                                  ),
                                );
                              } else if (index ==
                                  videosCurrentPage.floor() + 1) {
                                return Transform.scale(
                                  scale: (1.0 + (videosCurrentPage - index)),
                                  child: buildVideosListItems(
                                    tvShowYoutubeVideosResultsList[index],
                                    key,
                                    duration,
                                  ),
                                );
                              } else {
                                return buildVideosListItems(
                                  tvShowYoutubeVideosResultsList[index],
                                  key,
                                  duration,
                                );
                              }
                            }
                          },
                        ),
                      ),
                      Container(
                        height: 0.5,
                        margin: EdgeInsets.only(bottom: 0.0),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: tvShowImagesBackdropsList == null ||
                          tvShowImagesBackdropsList.length == 0
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Backdrops",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 250.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: backdropsPageController,
                                itemCount: tvShowImagesBackdropsList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == backdropsCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 -
                                          (backdropsCurrentPage - index)),
                                      child: buildImageListItems(
                                        tvShowImagesBackdropsList[index],
                                        index,
                                        tvShowImagesBackdropsList,
                                      ),
                                    );
                                  } else if (index ==
                                      backdropsCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 +
                                          (backdropsCurrentPage - index)),
                                      child: buildImageListItems(
                                        tvShowImagesBackdropsList[index],
                                        index,
                                        tvShowImagesBackdropsList,
                                      ),
                                    );
                                  } else {
                                    return buildImageListItems(
                                      tvShowImagesBackdropsList[index],
                                      index,
                                      tvShowImagesBackdropsList,
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: tvShowImagesPostersList == null ||
                          tvShowImagesPostersList.length == 0
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Posters",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 250.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: postersPageController,
                                itemCount: tvShowImagesPostersList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == postersCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 - (postersCurrentPage - index)),
                                      child: buildImageListItems(
                                        tvShowImagesPostersList[index],
                                        index,
                                        tvShowImagesPostersList,
                                      ),
                                    );
                                  } else if (index ==
                                      postersCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 + (postersCurrentPage - index)),
                                      child: buildImageListItems(
                                        tvShowImagesPostersList[index],
                                        index,
                                        tvShowImagesPostersList,
                                      ),
                                    );
                                  } else {
                                    return buildImageListItems(
                                      tvShowImagesPostersList[index],
                                      index,
                                      tvShowImagesPostersList,
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                SliverList(
                  delegate: tvShowSeasonsList == null ||
                          tvShowSeasonsList.length == 0
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
                          [
                            Container(
                              margin: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                              ),
                              child: Text(
                                "Seasons",
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w100,
                                  fontSize: 16,
                                  fontFamily: "ConcertOne-Regular",
                                ),
                              ),
                            ),
                            Container(
                              height: 330.0,
                              margin: EdgeInsets.only(
                                top: 10.0,
                              ),
                              child: PageView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: BouncingScrollPhysics(),
                                controller: seasonsPageController,
                                itemCount: tvShowSeasonsList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == seasonsCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 - (seasonsCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowSeasonsList[index].poster_path,
                                        tvShowSeasonsList[index].name,
                                        tvShowSeasonsList[index]
                                            .episode_count
                                            .toString(),
                                        tvShowSeasonsList[index].id.toString(),
                                        tvShowSeasonsList[index].season_number,
                                        "seasons",
                                      ),
                                    );
                                  } else if (index ==
                                      seasonsCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 + (seasonsCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvShowSeasonsList[index].poster_path,
                                        tvShowSeasonsList[index].name,
                                        tvShowSeasonsList[index]
                                            .episode_count
                                            .toString(),
                                        tvShowSeasonsList[index].id.toString(),
                                        tvShowSeasonsList[index].season_number,
                                        "seasons",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      tvShowSeasonsList[index].poster_path,
                                      tvShowSeasonsList[index].name,
                                      tvShowSeasonsList[index]
                                          .episode_count
                                          .toString(),
                                      tvShowSeasonsList[index].id.toString(),
                                      tvShowSeasonsList[index].season_number,
                                      "seasons",
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              height: 0.5,
                              margin: EdgeInsets.only(bottom: 0.0),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: Colors.black),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget buildCreatedByListItems(TvShowCreatedByModel tvShowCreatedByModel) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            NewPageTransition(
                widget: PersonDetails(
              personId: tvShowCreatedByModel.id,
            )));
      },
      child: Container(
        height: 220,
        margin: EdgeInsets.only(bottom: 10),
        child: Container(
          margin: EdgeInsets.only(
            left: 10.0,
            right: 15.0,
            top: 10.0,
            bottom: 15.0,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 4.0,
                spreadRadius: 1.0,
              ),
            ],
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: Stack(
            children: <Widget>[
              tvShowCreatedByModel.profile_path == null
                  ? Container(
                      height: 200,
                      width: screenWidth - 20,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.grey[100],
                          size: 80,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      child: Image.network(tvShowCreatedByModel.profile_path,
                          height: 200,
                          width: screenWidth - 20,
                          fit: BoxFit.cover),
                    ),
              tvShowCreatedByModel.name == "" ||
                      tvShowCreatedByModel.name == null
                  ? Container()
                  : Container(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 70.0,
                          width: screenWidth - 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0)),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black,
                                Colors.black.withOpacity(0.1)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
              tvShowCreatedByModel.name == "" ||
                      tvShowCreatedByModel.name == null
                  ? Container()
                  : Container(
                      width: screenWidth - 20,
                      padding: EdgeInsets.only(left: 20, bottom: 20, right: 3),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          tvShowCreatedByModel.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'CantoraOne-Regular',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildThreeLayerListItems(
    String imageUrl,
    String name,
    String subTitle,
    String heroId,
    int sendId,
    String type,
  ) {
    String sub = "";

    IconData icon = Icons.person;

    if (type == "cast") {
      sub = "Character : ";
      icon = Icons.person;
    } else if (type == "crew") {
      sub = "Department : ";
      icon = Icons.person;
    } else if (type == "networks" || type == "productionCompanies") {
      sub = "Origin Country : ";
      icon = Icons.business;
    } else if (type == "seasons") {
      sub = "Episodes : ";
      icon = Icons.tv;
    } else {
      sub = "";
    }

    return GestureDetector(
      onTap: () {
        if (type == "seasons") {
          Navigator.push(
              context,
              NewPageTransition(
                  widget: TvShowSeasonDetails(
                      tvShowId: tvShowId, tvShowSeasonNumber: sendId)));
        }

        if (type == "cast" || type == "crew") {
          Navigator.push(
              context,
              NewPageTransition(
                  widget: PersonDetails(
                personId: sendId,
              )));
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          left: 10.0,
          right: 15.0,
          top: 10.0,
          bottom: 15.0,
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Column(
          children: <Widget>[
            imageUrl == null
                ? Container(
                    height: 200,
                    width: screenWidth - 20,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: Colors.grey[100],
                        size: 80,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      width: screenWidth - 20,
                      fit: BoxFit.cover,
                    ),
                  ),
            name == "" || name == null
                ? Container()
                : Container(
                    height: 35,
                    width: screenWidth - 20,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.1)
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'CantoraOne-Regular',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
            subTitle == "" || subTitle == null
                ? Container()
                : Container(
                    height: 0.5,
                    margin: EdgeInsets.only(bottom: 0.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: Colors.black),
                      ],
                    ),
                  ),
            subTitle == "" || subTitle == null
                ? Container()
                : Container(
                    alignment: Alignment.center,
                    height: 59,
                    width: screenWidth - 20,
                    padding: EdgeInsets.only(
                      top: 10.0,
                      left: 5.0,
                      right: 5.0,
                      bottom: 5.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          sub,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'CantoraOne-Regular',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subTitle,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'CantoraOne-Regular',
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildVideosListItems(
      TvShowMovieVideosResultsModel tvShowYoutubeVideosResultsList,
      String key,
      String duration) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            NewPageTransition(
                widget: YoutubeVideoPlayerPage(
                    id: tvShowId,
                    playingVideoDetails: tvShowYoutubeVideosResultsList)));
      },
      child: Container(
        margin: EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          top: 10.0,
          bottom: 15.0,
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 4.0,
              spreadRadius: 1.0,
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              height: 1 / (16 / 9) * screenWidth,
              width: screenWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                child: Hero(
                    tag: key,
                    child: Image.network(
                      "https://i3.ytimg.com/vi/$key/sddefault.jpg",
                      fit: BoxFit.cover,
                    )),
              ),
            ),
            Container(
              height: 240,
              width: screenWidth - 10,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: EdgeInsets.all(7.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2.0),
                        bottomRight: Radius.circular(10.0)),
                  ),
                  child: Text(
                    duration,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageListItems(
      String imageUrl, int _currentIndex, List<String> _imagesList) {
    return imageUrl == null
        ? Container()
        : GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ZoomableImageView(
                          heroTag: imageUrl,
                          currentIndex: _currentIndex,
                          imagesList: _imagesList,
                        )),
              );
            },
            child: Container(
              margin: EdgeInsets.only(
                left: 10.0,
                right: 15.0,
                top: 10.0,
                bottom: 15.0,
              ),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                  ),
                ],
                border: Border.all(width: 0.0),
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              child: Hero(
                tag: imageUrl,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: Image.network(
                    imageUrl,
                    width: screenWidth - 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
  }
}
