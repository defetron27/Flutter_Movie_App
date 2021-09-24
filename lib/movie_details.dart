import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'Models/movie_cast_and_crew_cast_model.dart';
import 'Models/movie_cast_and_crew_crew_model.dart';
import 'Models/movie_cast_and_crew_model.dart';
import 'Models/tv_show_movie_genres_model.dart';
import 'Models/tv_show_movie_images_model.dart';
import 'Models/tv_show_movie_videos_model.dart';
import 'Models/tv_show_movie_videos_results_model.dart';
import 'Models/movie_details_model.dart';
import 'Models/tv_show_movie_production_companies_model.dart';
import 'Models/youtube_video_details_items_content_details_model.dart';
import 'Models/youtube_video_details_model.dart';

import 'Utils/GetLanguageName.dart';
import 'Utils/KenBurnsView.dart';
import 'Utils/LoadingBarIndicator.dart';
import 'Utils/NewPageTransition.dart';

import 'person_details.dart';
import 'youtube_video_player_page.dart';
import 'zoomable_image_view.dart';

class MovieDetails extends StatefulWidget {
  final int movieId;

  MovieDetails({Key key, @required this.movieId}) : super(key: key);

  _MovieDetailsState createState() => _MovieDetailsState(movieId);
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

class _MovieDetailsState extends State<MovieDetails>
    with TickerProviderStateMixin {
  MediaQueryData mediaQueryData;

  double screenWidth;
  double screenHeight;

  int movieId;

  MovieDetailsModel movieDetailsModel;

  var movieDetailsProductionCompaniesList =
      List<TvShowMovieProductionCompaniesModel>();

  var movieCastAndCrewCastList = List<MovieCastAndCrewCastModel>();
  var movieCastAndCrewCrewList = List<MovieCastAndCrewCrewModel>();

  TvShowMovieImagesModel movieImagesModel;
  var movieImagesBackdropsList = List<String>();
  var movieImagesPostersList = List<String>();

  TvShowMovieVideosModel movieVideosModel;
  var movieVideosResultsList = List<TvShowMovieVideosResultsModel>();
  var movieYoutubeVideosResults = List<TvShowMovieVideosResultsModel>();
  var youtubeVideosDurationsList = List<String>();

  var movieDetailsList = Map<String, String>();

  StringBuffer genresStringBuffer = StringBuffer();
  StringBuffer spokenLanguageStringBuffer = StringBuffer();
  StringBuffer productionCountriesStringBuffer = StringBuffer();

  _MovieDetailsState(this.movieId);

  Future<String> fetchMovieDetails() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/movie/$movieId?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        movieDetailsModel =
            MovieDetailsModel.fromJson(json.decode(response.body));
        movieDetailsProductionCompaniesList =
            movieDetailsModel.production_companies;

        var spokenLanguages = movieDetailsModel.spoken_languages;
        var productionCountries = movieDetailsModel.production_countries;
        List<TvShowMovieGenresModel> genres = movieDetailsModel.genres;

        for (int i = 0; i < spokenLanguages.length; i++) {
          if (movieDetailsModel.original_language.toLowerCase() !=
              spokenLanguages[i].iso_639_1.toLowerCase()) {
            if (i == movieDetailsModel.spoken_languages.length - 1) {
              spokenLanguageStringBuffer.write(GetLanguage()
                  .getLanguageName(spokenLanguages[i].iso_639_1)['name']);
            } else {
              spokenLanguageStringBuffer.write(GetLanguage()
                  .getLanguageName(spokenLanguages[i].iso_639_1)['name']);
              spokenLanguageStringBuffer.write(",");
            }
          }
        }

        for (int i = 0; i < genres.length; i++) {
          if (i == movieDetailsModel.genres.length - 1) {
            genresStringBuffer.write(genres[i].name);
          } else {
            genresStringBuffer.write(genres[i].name);
            genresStringBuffer.write(",");
          }
        }

        for (int i = 0; i < productionCountries.length; i++) {
          if (i == movieDetailsModel.production_countries.length - 1) {
            productionCountriesStringBuffer.write(productionCountries[i].name);
          } else {
            productionCountriesStringBuffer.write(productionCountries[i].name);
            productionCountriesStringBuffer.write(",");
          }
        }

        if (movieDetailsModel.status != "" &&
            movieDetailsModel.status != null) {
          movieDetailsList["Status"] = " : " + movieDetailsModel.status;
        }

        if (movieDetailsModel.release_date != "" &&
            movieDetailsModel.release_date != null) {
          String release = movieDetailsModel.status == "Released"
              ? "Released Date"
              : "Release Date";
          movieDetailsList[release] = " : " + movieDetailsModel.release_date;
        }

        if (movieDetailsModel.runtime != null) {
          movieDetailsList["Runtime"] =
              " : " + movieDetailsModel.runtime.toString() + " min";
        }

        if (movieDetailsModel.original_language != "" &&
            movieDetailsModel.original_language != null) {
          movieDetailsList["Original Language"] = " : " +
              GetLanguage()
                  .getLanguageName(movieDetailsModel.original_language)['name'];
        }

        if (movieDetailsModel.spoken_languages.length > 0 &&
            movieDetailsModel.spoken_languages != null) {
          movieDetailsList["Translated Languages"] =
              " : " + spokenLanguageStringBuffer.toString();
        }

        if (movieDetailsModel.genres.length > 0 &&
            movieDetailsModel.genres != null) {
          movieDetailsList["Genres"] = " : " + genresStringBuffer.toString();
        }

        if (movieDetailsModel.budget != null) {
          movieDetailsList["Budget"] =
              " : " + movieDetailsModel.budget.toString();
        }

        if (movieDetailsModel.revenue != null) {
          movieDetailsList["Revenue"] =
              " : " + movieDetailsModel.revenue.toString();
        }
        if (movieDetailsModel.adult) {
          movieDetailsList["Adult"] = " : Yes";
        } else {
          movieDetailsList["Adult"] = " : No";
        }

        if (movieDetailsModel.production_countries.length > 0 &&
            movieDetailsModel.production_countries != null) {
          movieDetailsList["Production Countries"] =
              " : " + productionCountriesStringBuffer.toString();
        }
      });
    }

    return "success";
  }

  Future fetchMovieCastAndCrew() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/movie/$movieId/credits?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        MovieCastAndCrewModel movieShowsCastAndCrewModel =
            MovieCastAndCrewModel.fromJson(json.decode(response.body));
        movieCastAndCrewCastList = movieShowsCastAndCrewModel.cast;
        movieCastAndCrewCrewList = movieShowsCastAndCrewModel.crew;
      });
    }
  }

  Future fetchMovieVideos() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        movieVideosModel =
            TvShowMovieVideosModel.fromJson(json.decode(response.body));
        movieVideosResultsList = movieVideosModel.results;

        for (var i in movieVideosResultsList) {
          if (i.site == "YouTube") {
            movieVideosResultsList.add(i);
          }
        }
        if (movieYoutubeVideosResults != null &&
            movieYoutubeVideosResults.length > 0) {
          fetchYoutubeVideoDetails(movieYoutubeVideosResults);
        }
      });
    }
  }

  Future fetchYoutubeVideoDetails(
      List<TvShowMovieVideosResultsModel> movieYoutubeVideosResults) async {
    var durationsList = List<String>();

    for (var youtubeVideos in movieYoutubeVideosResults) {
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

  Future fetchMovieImages() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/movie/$movieId/images?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        movieImagesModel =
            TvShowMovieImagesModel.fromJson(json.decode(response.body));
        movieImagesBackdropsList =
            movieImagesModel.backdrops.map((i) => i.file_path).toList();
        movieImagesPostersList =
            movieImagesModel.posters.map((i) => i.file_path).toList();
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

  PageController castPageController = PageController();
  double castCurrentPage = 0.0;

  PageController crewPageController = PageController();
  double crewCurrentPage = 0.0;

  PageController productionCompaniesPageController = PageController();
  double productionCompaniesCurrentPage = 0.0;

  PageController videosPageController = PageController();
  double videosCurrentPage = 0.0;

  PageController backdropsPageController = PageController();
  double backdropsCurrentPage = 0.0;

  PageController postersPageController = PageController();
  double postersCurrentPage = 0.0;

  @override
  void initState() {
    super.initState();

    this.fetchMovieDetails();
    this.fetchMovieCastAndCrew();
    // this.fetchMovieVideos();
    this.fetchMovieImages();

    _controller = ScrollController()..addListener(_scrollListener);

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

    productionCompaniesPageController.addListener(() {
      setState(() {
        productionCompaniesCurrentPage = productionCompaniesPageController.page;
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
      body: movieDetailsModel == null
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
                  leading: Container(
                    margin: EdgeInsets.only(
                      top: 25.0,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 20,
                    ),
                  ),
                  primary: false,
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
                  backgroundColor: Colors.purple[300],
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
                          movieDetailsModel.poster_path == null ||
                                  movieDetailsModel.poster_path == ""
                              ? Container(
                                  child: Icon(
                                    Icons.movie_creation,
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
                                        movieDetailsModel.poster_path,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                          movieDetailsModel.original_title == "" ||
                                  movieDetailsModel.original_title == null
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.only(
                                      left: 75.0,
                                      right: 75.0,
                                      top: 7.0,
                                      bottom: 25.0),
                                  child: Text(
                                    movieDetailsModel.original_title,
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
                    background: movieDetailsModel.backdrop_path == null ||
                            movieDetailsModel.backdrop_path == ""
                        ? Container(
                            color: Colors.grey,
                          )
                        : KenBurns(
                            url: movieDetailsModel.backdrop_path,
                            duration: 5000,
                            width: 800.0,
                            height: 800.0,
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      movieDetailsModel.vote_average == null
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
                                          movieDetailsModel.vote_average
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
                              movieDetailsList.entries.toList()[index].key,
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
                                movieDetailsList.entries.toList()[index].value,
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
                  }, childCount: movieDetailsList.length),
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
                          movieDetailsModel.overview,
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
                  delegate: movieCastAndCrewCastList == null ||
                          movieCastAndCrewCastList.length == 0
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
                                "Movie Cast",
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
                                itemCount: movieCastAndCrewCastList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == castCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 - (castCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        movieCastAndCrewCastList[index]
                                            .profile_path,
                                        movieCastAndCrewCastList[index].name,
                                        movieCastAndCrewCastList[index]
                                            .character,
                                        movieCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        movieCastAndCrewCastList[index].id,
                                        "cast",
                                      ),
                                    );
                                  } else if (index ==
                                      castCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 + (castCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        movieCastAndCrewCastList[index]
                                            .profile_path,
                                        movieCastAndCrewCastList[index].name,
                                        movieCastAndCrewCastList[index]
                                            .character,
                                        movieCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        movieCastAndCrewCastList[index].id,
                                        "cast",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      movieCastAndCrewCastList[index]
                                          .profile_path,
                                      movieCastAndCrewCastList[index].name,
                                      movieCastAndCrewCastList[index].character,
                                      movieCastAndCrewCastList[index]
                                          .credit_id
                                          .toString(),
                                      movieCastAndCrewCastList[index].id,
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
                  delegate: movieCastAndCrewCrewList == null ||
                          movieCastAndCrewCrewList.length == 0
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
                                "Movie Crew",
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
                                itemCount: movieCastAndCrewCrewList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == crewCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 - (crewCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        movieCastAndCrewCrewList[index]
                                            .profile_path,
                                        movieCastAndCrewCrewList[index].name,
                                        movieCastAndCrewCrewList[index]
                                            .department,
                                        movieCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        movieCastAndCrewCrewList[index].id,
                                        "crew",
                                      ),
                                    );
                                  } else if (index ==
                                      crewCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 + (crewCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        movieCastAndCrewCrewList[index]
                                            .profile_path,
                                        movieCastAndCrewCrewList[index].name,
                                        movieCastAndCrewCrewList[index]
                                            .department,
                                        movieCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        movieCastAndCrewCrewList[index].id,
                                        "crew",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      movieCastAndCrewCrewList[index]
                                          .profile_path,
                                      movieCastAndCrewCrewList[index].name,
                                      movieCastAndCrewCrewList[index]
                                          .department,
                                      movieCastAndCrewCrewList[index]
                                          .credit_id
                                          .toString(),
                                      movieCastAndCrewCrewList[index].id,
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
                  delegate: movieDetailsProductionCompaniesList == null ||
                          movieDetailsProductionCompaniesList.length == 0
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
                                itemCount:
                                    movieDetailsProductionCompaniesList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index ==
                                      productionCompaniesCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 -
                                          (productionCompaniesCurrentPage -
                                              index)),
                                      child: buildThreeLayerListItems(
                                        movieDetailsProductionCompaniesList[
                                                index]
                                            .logo_path,
                                        movieDetailsProductionCompaniesList[
                                                index]
                                            .name,
                                        movieDetailsProductionCompaniesList[
                                                index]
                                            .origin_country,
                                        movieDetailsProductionCompaniesList[
                                                index]
                                            .id
                                            .toString(),
                                        movieDetailsProductionCompaniesList[
                                                index]
                                            .id,
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
                                        movieDetailsProductionCompaniesList[
                                                index]
                                            .logo_path,
                                        movieDetailsProductionCompaniesList[
                                                index]
                                            .name,
                                        movieDetailsProductionCompaniesList[
                                                index]
                                            .origin_country,
                                        movieDetailsProductionCompaniesList[
                                                index]
                                            .id
                                            .toString(),
                                        movieDetailsProductionCompaniesList[
                                                index]
                                            .id,
                                        "productionCompanies",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      movieDetailsProductionCompaniesList[index]
                                          .logo_path,
                                      movieDetailsProductionCompaniesList[index]
                                          .name,
                                      movieDetailsProductionCompaniesList[index]
                                          .origin_country,
                                      movieDetailsProductionCompaniesList[index]
                                          .id
                                          .toString(),
                                      movieDetailsProductionCompaniesList[index]
                                          .id,
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
                          itemCount: movieYoutubeVideosResults.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (movieYoutubeVideosResults[index].key == null ||
                                youtubeVideosDurationsList.length <= 0 ||
                                youtubeVideosDurationsList[index] == null) {
                              return Container();
                            } else {
                              String key = movieYoutubeVideosResults[index].key;

                              String duration =
                                  youtubeVideosDurationsList[index];

                              if (index == videosCurrentPage.floor()) {
                                return Transform.scale(
                                  scale: (1.0 - (videosCurrentPage - index)),
                                  child: buildVideosListItems(
                                    movieYoutubeVideosResults[index],
                                    key,
                                    duration,
                                  ),
                                );
                              } else if (index ==
                                  videosCurrentPage.floor() + 1) {
                                return Transform.scale(
                                  scale: (1.0 + (videosCurrentPage - index)),
                                  child: buildVideosListItems(
                                    movieYoutubeVideosResults[index],
                                    key,
                                    duration,
                                  ),
                                );
                              } else {
                                return buildVideosListItems(
                                  movieYoutubeVideosResults[index],
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
                  delegate: movieImagesBackdropsList == null ||
                          movieImagesBackdropsList.length == 0
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
                                itemCount: movieImagesBackdropsList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == backdropsCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 -
                                          (backdropsCurrentPage - index)),
                                      child: buildImageListItems(
                                        movieImagesBackdropsList[index],
                                        index,
                                        movieImagesBackdropsList,
                                      ),
                                    );
                                  } else if (index ==
                                      backdropsCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 +
                                          (backdropsCurrentPage - index)),
                                      child: buildImageListItems(
                                        movieImagesBackdropsList[index],
                                        index,
                                        movieImagesBackdropsList,
                                      ),
                                    );
                                  } else {
                                    return buildImageListItems(
                                      movieImagesBackdropsList[index],
                                      index,
                                      movieImagesBackdropsList,
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
                  delegate: movieImagesPostersList.length == 0 ||
                          movieImagesPostersList == null
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
                                itemCount: movieImagesPostersList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == postersCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 - (postersCurrentPage - index)),
                                      child: buildImageListItems(
                                        movieImagesPostersList[index],
                                        index,
                                        movieImagesPostersList,
                                      ),
                                    );
                                  } else if (index ==
                                      postersCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 + (postersCurrentPage - index)),
                                      child: buildImageListItems(
                                        movieImagesPostersList[index],
                                        index,
                                        movieImagesPostersList,
                                      ),
                                    );
                                  } else {
                                    return buildImageListItems(
                                      movieImagesPostersList[index],
                                      index,
                                      movieImagesPostersList,
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
    } else if (type == "productionCompanies") {
      sub = "Origin Country : ";
      icon = Icons.business;
    } else {
      sub = "";
    }

    return GestureDetector(
      onTap: () {
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
      TvShowMovieVideosResultsModel movieYoutubeVideosResults,
      String key,
      String duration) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            NewPageTransition(
                widget: YoutubeVideoPlayerPage(
                    id: movieId,
                    playingVideoDetails: movieYoutubeVideosResults)));
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
