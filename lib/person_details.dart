import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Models/person_details_movie_cast_and_crew_cast_model.dart';
import 'Models/person_details_movie_cast_and_crew_crew_model.dart';
import 'Models/person_details_movie_cast_and_crew_model.dart';
import 'Models/person_details_model.dart';
import 'Models/person_details_tv_cast_and_crew_cast_model.dart';
import 'Models/person_details_tv_cast_and_crew_crew_model.dart';
import 'Models/person_details_tv_cast_and_crew_model.dart';
import 'Models/person_images_model.dart';

import 'Utils/LoadingBarIndicator.dart';
import 'Utils/NewPageTransition.dart';

import 'zoomable_image_view.dart';
import 'movie_details.dart';
import 'tv_show_details.dart';

class PersonDetails extends StatefulWidget {
  final int personId;

  PersonDetails({Key key, @required this.personId}) : super(key: key);

  _PersonDetailsState createState() => _PersonDetailsState(personId);
}

class _PersonDetailsState extends State<PersonDetails> {
  MediaQueryData mediaQueryData;

  double screenWidth;
  double screenHeight;

  int personId;

  PersonDetailsModel personDetailsModel;

  StringBuffer personAlsoKnownAs = StringBuffer();

  var personDetailsList = Map<String, String>();

  List<PersonDetailsMovieCastAndCrewCastModel> movieCastAndCrewCastList;
  List<PersonDetailsMovieCastAndCrewCrewModel> movieCastAndCrewCrewList;

  List<PersonDetailsTvCastAndCrewCastModel> tvCastAndCrewCastList;
  List<PersonDetailsTvCastAndCrewCrewModel> tvCastAndCrewCrewList;

  PersonImagesModel personImagesModel;
  var personImagesProfilesList = List<String>();

  _PersonDetailsState(int personId) {
    this.personId = personId;
  }

  Future<String> fetchPersonDetails() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/person/$personId?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});

    if (this.mounted) {
      setState(() {
        personDetailsModel =
            PersonDetailsModel.fromJson(json.decode(response.body));

        List<String> alsoKnownAsList = personDetailsModel.also_known_as;

        for (int i = 0; i < alsoKnownAsList.length; i++) {
          if (i == alsoKnownAsList.length - 1) {
            personAlsoKnownAs.write(alsoKnownAsList[i]);
          } else {
            personAlsoKnownAs.write(alsoKnownAsList[i]);
            personAlsoKnownAs.write(",");
          }
        }

        if (alsoKnownAsList.length > 0 && alsoKnownAsList != null) {
          personDetailsList["Also Known As"] =
              " : " + personAlsoKnownAs.toString();
        }

        if (personDetailsModel.gender != 0 &&
            personDetailsModel.gender != null) {
          String gender = personDetailsModel.gender == 1 ? "Female" : "Male";
          personDetailsList["Gender"] = " : " + gender;
        }

        if (personDetailsModel.adult != null) {
          String adult = personDetailsModel.adult ? "Yes" : "No";
          personDetailsList["Adult"] = " : " + adult;
        }

        if (personDetailsModel.birthday != "" &&
            personDetailsModel.birthday != null) {
          personDetailsList["Date of Birth"] =
              " : " + personDetailsModel.birthday;
        }

        if (personDetailsModel.place_of_birth != "" &&
            personDetailsModel.place_of_birth != null) {
          personDetailsList["Place of Birth"] =
              " : " + personDetailsModel.place_of_birth;
        }

        if (personDetailsModel.deathday != "" &&
            personDetailsModel.deathday != null) {
          personDetailsList["Deathday"] = " : " + personDetailsModel.deathday;
        }

        if (personDetailsModel.known_for_department != "" &&
            personDetailsModel.known_for_department != null) {
          personDetailsList["Known for Department"] =
              " : " + personDetailsModel.known_for_department;
        }
      });
    }

    return "success";
  }

  Future fetchPersonDetailsMovieCastAndCrew() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/person/$personId/movie_credits?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        PersonDetailsMovieCastAndCrewModel personDetailsMovieCastAndCrewModel =
            PersonDetailsMovieCastAndCrewModel.fromJson(
                json.decode(response.body));

        movieCastAndCrewCastList = personDetailsMovieCastAndCrewModel.cast;
        movieCastAndCrewCrewList = personDetailsMovieCastAndCrewModel.crew;
      });
    }
  }

  Future fetchPersonDetailsTvCastAndCrew() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/person/$personId/tv_credits?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        PersonDetailsTvCastAndCrewModel personDetailsTvCastAndCrewModel =
            PersonDetailsTvCastAndCrewModel.fromJson(
                json.decode(response.body));

        tvCastAndCrewCastList = personDetailsTvCastAndCrewModel.cast;
        tvCastAndCrewCrewList = personDetailsTvCastAndCrewModel.crew;
      });
    }
  }

  Future fetchPersonImages() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/person/$personId/images?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});
    if (this.mounted) {
      setState(() {
        personImagesModel =
            PersonImagesModel.fromJson(json.decode(response.body));
        personImagesProfilesList =
            personImagesModel.profiles.map((i) => i.file_path).toList();
      });
    }
  }

  ScrollController scrollController;

  double offset = 0.0;

  PageController movieCastPageController = PageController();
  double movieCastCurrentPage = 0.0;

  PageController movieCrewPageController = PageController();
  double movieCrewCurrentPage = 0.0;

  PageController tvCastPageController = PageController();
  double tvCastCurrentPage = 0.0;

  PageController tvCrewPageController = PageController();
  double tvCrewCurrentPage = 0.0;

  PageController profilesPageController = PageController();
  double profilesCurrentPage = 0.0;

  @override
  void initState() {
    super.initState();

    this.fetchPersonDetails();
    this.fetchPersonDetailsMovieCastAndCrew();
    this.fetchPersonDetailsTvCastAndCrew();
    this.fetchPersonImages();

    scrollController = ScrollController()..addListener(_scrollListener);

    movieCastPageController.addListener(() {
      setState(() {
        movieCastCurrentPage = movieCastPageController.page;
      });
    });

    movieCrewPageController.addListener(() {
      setState(() {
        movieCrewCurrentPage = movieCrewPageController.page;
      });
    });

    tvCastPageController.addListener(() {
      setState(() {
        tvCastCurrentPage = tvCastPageController.page;
      });
    });

    tvCrewPageController.addListener(() {
      setState(() {
        tvCrewCurrentPage = tvCrewPageController.page;
      });
    });

    profilesPageController.addListener(() {
      setState(() {
        profilesCurrentPage = profilesPageController.page;
      });
    });
  }

  _scrollListener() {
    if (this.mounted) {
      if (scrollController.hasClients) {
        setState(() {
          offset = scrollController.offset;
        });
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
      body: personDetailsModel == null
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
              controller: scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  leading: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 17,
                  ),
                  expandedHeight: 470,
                  pinned: true,
                  floating: false,
                  snap: false,
                  backgroundColor: Colors.blue[200],
                  centerTitle: false,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(
                      personDetailsModel.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "ConcertOne-Regular",
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    background: personDetailsModel.profile_path == null ||
                            personDetailsModel.profile_path == ""
                        ? Container(
                            color: Colors.grey,
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.grey[100],
                              ),
                            ),
                          )
                        : Container(
                            child: Image.network(
                              personDetailsModel.profile_path,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
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
                  delegate:
                      personDetailsList == null || personDetailsList.length == 0
                          ? SliverChildListDelegate([])
                          : SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                              return Container(
                                margin: EdgeInsets.only(
                                  left: 15.0,
                                  right: 15.0,
                                  top: 10.0,
                                  bottom: 5.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        personDetailsList.entries
                                            .toList()[index]
                                            .key,
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
                                          personDetailsList.entries
                                              .toList()[index]
                                              .value,
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
                            }, childCount: personDetailsList.length),
                ),
                SliverList(
                  delegate: personDetailsModel.biography == null ||
                          personDetailsModel.biography == ""
                      ? SliverChildListDelegate([])
                      : SliverChildListDelegate(
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
                                personDetailsModel.biography,
                                textAlign: TextAlign.start,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
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
                              height: 0.5,
                              margin: EdgeInsets.only(
                                top: 10.0,
                                bottom: 0.0,
                              ),
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
                                "Cast in Movies",
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
                                controller: movieCastPageController,
                                itemCount: movieCastAndCrewCastList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == movieCastCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 -
                                          (movieCastCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        movieCastAndCrewCastList[index]
                                            .poster_path,
                                        movieCastAndCrewCastList[index].title,
                                        movieCastAndCrewCastList[index]
                                            .character,
                                        movieCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        movieCastAndCrewCastList[index].id,
                                        "movieCast",
                                      ),
                                    );
                                  } else if (index ==
                                      movieCastCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 +
                                          (movieCastCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        movieCastAndCrewCastList[index]
                                            .poster_path,
                                        movieCastAndCrewCastList[index].title,
                                        movieCastAndCrewCastList[index]
                                            .character,
                                        movieCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        movieCastAndCrewCastList[index].id,
                                        "movieCast",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      movieCastAndCrewCastList[index]
                                          .poster_path,
                                      movieCastAndCrewCastList[index].title,
                                      movieCastAndCrewCastList[index].character,
                                      movieCastAndCrewCastList[index]
                                          .credit_id
                                          .toString(),
                                      movieCastAndCrewCastList[index].id,
                                      "movieCast",
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
                                "Crew in Movies",
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
                                controller: movieCrewPageController,
                                itemCount: movieCastAndCrewCrewList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == movieCrewCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale: (1.0 -
                                          (movieCrewCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        movieCastAndCrewCrewList[index]
                                            .poster_path,
                                        movieCastAndCrewCrewList[index].title,
                                        movieCastAndCrewCrewList[index]
                                            .department,
                                        movieCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        movieCastAndCrewCrewList[index].id,
                                        "movieCrew",
                                      ),
                                    );
                                  } else if (index ==
                                      movieCrewCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale: (1.0 +
                                          (movieCrewCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        movieCastAndCrewCrewList[index]
                                            .poster_path,
                                        movieCastAndCrewCrewList[index].title,
                                        movieCastAndCrewCrewList[index]
                                            .department,
                                        movieCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        movieCastAndCrewCrewList[index].id,
                                        "movieCrew",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      movieCastAndCrewCrewList[index]
                                          .poster_path,
                                      movieCastAndCrewCrewList[index].title,
                                      movieCastAndCrewCrewList[index]
                                          .department,
                                      movieCastAndCrewCrewList[index]
                                          .credit_id
                                          .toString(),
                                      movieCastAndCrewCrewList[index].id,
                                      "movieCrew",
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
                  delegate: tvCastAndCrewCastList == null ||
                          tvCastAndCrewCastList.length == 0
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
                                "Cast in TvShows",
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
                                controller: tvCastPageController,
                                itemCount: tvCastAndCrewCastList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == tvCastCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 - (tvCastCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvCastAndCrewCastList[index]
                                            .poster_path,
                                        tvCastAndCrewCastList[index].name,
                                        tvCastAndCrewCastList[index].character,
                                        tvCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        tvCastAndCrewCastList[index].id,
                                        "tvCast",
                                      ),
                                    );
                                  } else if (index ==
                                      tvCastCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 + (tvCastCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvCastAndCrewCastList[index]
                                            .poster_path,
                                        tvCastAndCrewCastList[index].name,
                                        tvCastAndCrewCastList[index].character,
                                        tvCastAndCrewCastList[index]
                                            .credit_id
                                            .toString(),
                                        tvCastAndCrewCastList[index].id,
                                        "tvCast",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      tvCastAndCrewCastList[index].poster_path,
                                      tvCastAndCrewCastList[index].name,
                                      tvCastAndCrewCastList[index].character,
                                      tvCastAndCrewCastList[index]
                                          .credit_id
                                          .toString(),
                                      tvCastAndCrewCastList[index].id,
                                      "tvCast",
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
                  delegate: tvCastAndCrewCrewList == null ||
                          tvCastAndCrewCrewList.length == 0
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
                                "Crew in TvShows",
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
                                controller: tvCrewPageController,
                                itemCount: tvCastAndCrewCrewList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == tvCrewCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 - (tvCrewCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvCastAndCrewCrewList[index]
                                            .poster_path,
                                        tvCastAndCrewCrewList[index]
                                            .original_name,
                                        tvCastAndCrewCrewList[index].department,
                                        tvCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        tvCastAndCrewCrewList[index].id,
                                        "tvCrew",
                                      ),
                                    );
                                  } else if (index ==
                                      tvCrewCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 + (tvCrewCurrentPage - index)),
                                      child: buildThreeLayerListItems(
                                        tvCastAndCrewCrewList[index]
                                            .poster_path,
                                        tvCastAndCrewCrewList[index]
                                            .original_name,
                                        tvCastAndCrewCrewList[index].department,
                                        tvCastAndCrewCrewList[index]
                                            .credit_id
                                            .toString(),
                                        tvCastAndCrewCrewList[index].id,
                                        "tvCrew",
                                      ),
                                    );
                                  } else {
                                    return buildThreeLayerListItems(
                                      tvCastAndCrewCrewList[index].poster_path,
                                      tvCastAndCrewCrewList[index]
                                          .original_name,
                                      tvCastAndCrewCrewList[index].department,
                                      tvCastAndCrewCrewList[index]
                                          .credit_id
                                          .toString(),
                                      tvCastAndCrewCrewList[index].id,
                                      "tvCrew",
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
                  delegate: personImagesProfilesList == null ||
                          personImagesProfilesList.length == 0
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
                                controller: profilesPageController,
                                itemCount: personImagesProfilesList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == profilesCurrentPage.floor()) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 - (profilesCurrentPage - index)),
                                      child: buildImageListItems(
                                        personImagesProfilesList[index],
                                        index,
                                        personImagesProfilesList,
                                      ),
                                    );
                                  } else if (index ==
                                      profilesCurrentPage.floor() + 1) {
                                    return Transform.scale(
                                      scale:
                                          (1.0 + (profilesCurrentPage - index)),
                                      child: buildImageListItems(
                                        personImagesProfilesList[index],
                                        index,
                                        personImagesProfilesList,
                                      ),
                                    );
                                  } else {
                                    return buildImageListItems(
                                      personImagesProfilesList[index],
                                      index,
                                      personImagesProfilesList,
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

    if (type == "movieCast" || type == "tvCast") {
      sub = "Character : ";
      if (type == "movieCast") {
        icon = Icons.movie;
      } else {
        icon = Icons.live_tv;
      }
    } else if (type == "movieCrew" || type == "tvCrew") {
      sub = "Department : ";
      if (type == "movieCrew") {
        icon = Icons.movie;
      } else {
        icon = Icons.live_tv;
      }
    } else {
      sub = "";
    }

    return GestureDetector(
      onTap: () {
        if (type == "movieCast" || type == "movieCrew") {
          Navigator.push(
              context,
              NewPageTransition(
                  widget: MovieDetails(
                movieId: sendId,
              )));
        }

        if (type == "tvCast" || type == "tvCrew") {
          Navigator.push(
              context,
              NewPageTransition(
                  widget: TvShowDetails(
                tvShowId: sendId,
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
