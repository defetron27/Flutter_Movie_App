import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:vector_math/vector_math_64.dart' as VectorMath64;
import 'package:flutter_pagewise/flutter_pagewise.dart';

import 'Models/default_main_movie_model.dart';
import 'Models/default_main_movie_results_model.dart';
import 'Models/default_main_person_model.dart';
import 'Models/default_main_person_results_model.dart';
import 'Models/default_main_tv_show_model.dart';
import 'Models/default_main_tv_show_results_model.dart';

import 'Utils/LoadingBarIndicator.dart';
import 'Utils/NewPageTransition.dart';
import 'Utils/custom_curved_navigation_bar.dart';

import 'tv_show_details.dart';

void main() => runApp(MaterialApp(
      title: "Media Base",
      debugShowCheckedModeBanner: false,
      home: MediaBase(),
    ));

class MediaBase extends StatefulWidget {
  MediaBase({Key key}) : super(key: key);

  _MediaBaseState createState() => _MediaBaseState();
}

class _MediaBaseState extends State<MediaBase> with TickerProviderStateMixin {
  MediaQueryData mediaQueryData;

  double screenWidth;
  double screenHeight;

  int _currentIndex = 1;
  int _currentSliderIndex = 0;

  int totalPopularPages = 1;
  int currentPopularPage = 1;

  List<Color> _bgColorList = [
    Colors.green[400],
    Colors.deepPurple[400],
    Colors.blue[400],
  ];

  List _tabBarTextList = ["Tv Shows", "Movies", "Celebrities"];

  List<Widget> iconList(double _size, Color _color) {
    var iconList = List<Widget>();

    iconList.add(Icon(
      Icons.live_tv,
      size: _size,
      color: _color,
    ));
    iconList.add(Icon(
      Icons.movie,
      size: _size,
      color: _color,
    ));
    iconList.add(Icon(
      Icons.people_outline,
      size: _size,
      color: _color,
    ));

    return iconList;
  }

  List<Color> buildLoadingBarColors() {
    var _colors = List<Color>();

    _colors.add(Colors.green);
    _colors.add(Colors.blue);
    _colors.add(Colors.yellow);
    _colors.add(Colors.purple);
    _colors.add(Colors.deepOrange);

    return _colors;
  }

  var sliderItemDetailsList = List<Map<String, String>>();
  var customSliderItemDetailsList = List<Map<String, String>>();

  AnimationController dragAnimationController;
  AnimationController sliderAnimationController;
  AnimationController sliderEntryAnimationController;
  AnimationController sliderTextEntryAnimationController;

  AnimationController mainPageTextEntryAnimationController;

  AnimationController listItemEntryAnimationController;

  AnimationController popularListItemTextEntryAnimationController;
  AnimationController topRatedListItemTextEntryAnimationController;
  AnimationController releasingTodayListItemTextEntryAnimationController;
  AnimationController nowPlayingListItemTextEntryAnimationController;

  double defaultSlidingValue = 1.0 / 4.0;

  double currentSlidingValue = 1.0 / 4.0;

  var randomSliderPosition = Random();

  var randomSliderPositionsList = List<int>();

  bool _animationStatus = false;

  int endTvRange;
  int beginMovieRange;
  int endMovieRange;
  int beginPersonRange;
  int endPersonRange;
  int beginGameRange;
  int endGameRange;

  Animation<double> heightFactorAnimation;
  Animation<double> cornerRadiusAnimation;
  Animation<double> colorOpacityAnimation;
  Animation<double> opacityAnimation;
  Animation<double> sliderTextEntryAnimation;
  Animation<double> sliderTopCenterOpacityAnimation;

  double collapsedHeightFactor = 0.60;
  double expandedHeightFactor = 0.20;

  double collapsedCornerRadius = 0.0;
  double expandedCornerRadius = 30.0;

  double expandedColorOpacity = 0.0;
  double collapsedColorOpacity = 1.0;

  double expandedOpacity = 1.0;
  double collapsedOpacity = 0.0;

  double collapsedSliderTopCenterOpacity = 0.0;
  double expandedSliderTopCenterOpacity = 0.2;

  PageController mainSliderPageController;
  double mainSliderCurrentPage = 0.0;

  PageController popularPageController;
  double popularCurrentPage = 0.0;

  PageController topRatedPageController;
  double topRatedCurrentPage = 0.0;

  PageController releasingTodayPageController;
  double releasingTodayCurrentPage = 0.0;

  PageController nowPlayingPageController;
  double nowPlayingCurrentPage = 0.0;

  var tvTrendingList = List<DefaultMainTvShowResultsModel>();
  var movieTrendingList = List<DefaultMainMovieResultsModel>();
  var personTrendingList = List<DefaultMainPersonResultsModel>();

  // var tvShowPopularList = List<DefaultMainTvShowResultsModel>();
  var tvShowTopRatedList = List<DefaultMainTvShowResultsModel>();
  var tvShowReleasingTodayList = List<DefaultMainTvShowResultsModel>();
  var tvShowNowPlayingList = List<DefaultMainTvShowResultsModel>();

  Future fetchMainSliderItems() async {
    var _sliderItemDetails = List<Map<String, String>>();

    DefaultMainTvShowModel tvResponseModel;
    DefaultMainMovieModel movieResponseModel;
    DefaultMainPersonModel personResponseModel;

    final tvResponse = await http.get(
      Uri.encodeFull(
          'https://api.themoviedb.org/3/trending/tv/day?api_key=63e2f7bc00c513994d63c9be541a08d1'),
      headers: {
        "Accept": "application/json",
      },
    );

    final movieResponse = await http.get(
      Uri.encodeFull(
          'https://api.themoviedb.org/3/trending/movie/day?api_key=63e2f7bc00c513994d63c9be541a08d1'),
      headers: {
        "Accept": "application/json",
      },
    );

    final personResponse = await http.get(
      Uri.encodeFull(
          'https://api.themoviedb.org/3/trending/person/day?api_key=63e2f7bc00c513994d63c9be541a08d1'),
      headers: {
        "Accept": "application/json",
      },
    );

    if (this.mounted) {
      setState(() {
        if (tvResponse.statusCode == 200) {
          tvResponseModel =
              DefaultMainTvShowModel.fromJson(json.decode(tvResponse.body));
        }

        if (movieResponse.statusCode == 200) {
          movieResponseModel =
              DefaultMainMovieModel.fromJson(json.decode(movieResponse.body));
        }

        if (personResponse.statusCode == 200) {
          personResponseModel =
              DefaultMainPersonModel.fromJson(json.decode(personResponse.body));
        }

        if (tvResponseModel != null && tvResponseModel.results.length > 0) {
          tvTrendingList = tvResponseModel.results;
        }

        if (movieResponseModel != null &&
            movieResponseModel.results.length > 0) {
          movieTrendingList = movieResponseModel.results;
        }

        if (personResponseModel != null &&
            personResponseModel.results.length > 0) {
          personTrendingList = personResponseModel.results;
        }

        if (tvTrendingList != null && tvTrendingList.length > 0) {
          for (DefaultMainTvShowResultsModel tvTrending in tvTrendingList) {
            if (tvTrending.name != null &&
                tvTrending.name != "" &&
                tvTrending.backdrop_path != null &&
                tvTrending.backdrop_path != "") {
              if (_sliderItemDetails.length <= 3) {
                _sliderItemDetails.add({
                  "imageUrl": tvTrending.backdrop_path,
                  "name": tvTrending.name
                });
              }
            }
          }

          if (_sliderItemDetails != null && _sliderItemDetails.length > 0) {
            sliderItemDetailsList.addAll(_sliderItemDetails);
            endTvRange = _sliderItemDetails.length;
            beginMovieRange = endTvRange;
            _sliderItemDetails.clear();
          }
        }

        if (movieTrendingList != null && movieTrendingList.length > 0) {
          for (DefaultMainMovieResultsModel movieTrending
              in movieTrendingList) {
            if (movieTrending.title != null &&
                movieTrending.title != "" &&
                movieTrending.backdrop_path != null &&
                movieTrending.backdrop_path != "") {
              if (_sliderItemDetails.length <= 3) {
                _sliderItemDetails.add({
                  "imageUrl": movieTrending.backdrop_path,
                  "name": movieTrending.title
                });
              }
            }
          }

          if (_sliderItemDetails != null && _sliderItemDetails.length > 0) {
            sliderItemDetailsList.addAll(_sliderItemDetails);
            endMovieRange = beginMovieRange + _sliderItemDetails.length;
            beginPersonRange = endMovieRange;
            _sliderItemDetails.clear();
          }
        }

        if (personTrendingList != null && personTrendingList.length > 0) {
          for (DefaultMainPersonResultsModel personTrending
              in personTrendingList) {
            if (personTrending.name != null &&
                personTrending.name != "" &&
                personTrending.profile_path != null &&
                personTrending.profile_path != "") {
              if (_sliderItemDetails.length <= 3) {
                _sliderItemDetails.add({
                  "imageUrl": personTrending.profile_path,
                  "name": personTrending.name
                });
              }
            }
          }

          if (_sliderItemDetails != null && _sliderItemDetails.length > 0) {
            sliderItemDetailsList.addAll(_sliderItemDetails);
            endPersonRange = beginPersonRange + _sliderItemDetails.length;
            beginGameRange = endPersonRange;
            _sliderItemDetails.clear();
          }
        }

        if (sliderItemDetailsList != null && sliderItemDetailsList.length > 0) {
          if (_currentIndex == 0) {
            customSliderItemDetailsList.clear();
            customSliderItemDetailsList =
                sliderItemDetailsList.sublist(0, endTvRange);

            customSliderItemDetailsList.shuffle();
          } else if (_currentIndex == 1) {
            customSliderItemDetailsList.clear();
            customSliderItemDetailsList =
                sliderItemDetailsList.sublist(beginMovieRange, endMovieRange);

            customSliderItemDetailsList.shuffle();
          } else if (_currentIndex == 2) {
            customSliderItemDetailsList.clear();
            customSliderItemDetailsList =
                sliderItemDetailsList.sublist(beginPersonRange, endPersonRange);

            customSliderItemDetailsList.shuffle();
          }

          if (customSliderItemDetailsList != null &&
              customSliderItemDetailsList.length > 0) {
            for (int i = 0; i < customSliderItemDetailsList.length; i++) {
              randomSliderPositionsList.add(i);
            }

            double sliderLength = customSliderItemDetailsList.length.toDouble();

            defaultSlidingValue = 1.0 / sliderLength;
            currentSlidingValue = 1.0 / sliderLength;
          }
        }
      });
    }
  }

  Future<List<DefaultMainTvShowResultsModel>> fetchPopularItems(
      int page) async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/popular?api_key=63e2f7bc00c513994d63c9be541a08d1&page=$page'),
        headers: {"Accept": "application/json"});

    if (this.mounted) {
      setState(() {
        DefaultMainTvShowModel defaultTvShowMainModel =
            DefaultMainTvShowModel.fromJson(json.decode(response.body));
        totalPopularPages = defaultTvShowMainModel.total_pages;
        currentPopularPage = page + 1;
        return defaultTvShowMainModel.results;
      });
    }

    return null;

    // listItemEntryAnimationController.forward();
    // popularListItemTextEntryAnimationController.forward();
    // tvShowPopularList.shuffle();
  }

  Future fetchTopRatedItems() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/top_rated?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});

    if (this.mounted) {
      setState(() {
        DefaultMainTvShowModel defaultTvShowMainModel =
            DefaultMainTvShowModel.fromJson(json.decode(response.body));
        tvShowTopRatedList = defaultTvShowMainModel.results;
        tvShowTopRatedList.shuffle();
      });
    }

    topRatedListItemTextEntryAnimationController.forward();
  }

  Future fetchReleasingTodayItems() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/airing_today?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});

    if (this.mounted) {
      setState(() {
        DefaultMainTvShowModel defaultTvShowMainModel =
            DefaultMainTvShowModel.fromJson(json.decode(response.body));
        tvShowReleasingTodayList = defaultTvShowMainModel.results;
        tvShowReleasingTodayList.shuffle();
      });
    }

    releasingTodayListItemTextEntryAnimationController.forward();
  }

  Future fetchNowPlayingItems() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/on_the_air?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});

    if (this.mounted) {
      setState(() {
        DefaultMainTvShowModel defaultTvShowMainModel =
            DefaultMainTvShowModel.fromJson(json.decode(response.body));
        tvShowNowPlayingList = defaultTvShowMainModel.results;
        tvShowNowPlayingList.shuffle();
      });
    }

    nowPlayingListItemTextEntryAnimationController.forward();
  }

  ScrollController mainPageController;

  PageStorageBucket storageBucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();

    this.fetchMainSliderItems();

    mainSliderPageController = PageController();
    mainSliderPageController.addListener(() {
      setState(() {
        mainSliderCurrentPage = mainSliderPageController.page;
      });
    });

    dragAnimationController = AnimationController(
      vsync: this,
    );

    heightFactorAnimation =
        Tween(begin: collapsedHeightFactor, end: expandedHeightFactor)
            .animate(dragAnimationController);

    cornerRadiusAnimation =
        Tween(begin: expandedCornerRadius, end: collapsedCornerRadius)
            .animate(dragAnimationController);

    colorOpacityAnimation =
        Tween(begin: expandedColorOpacity, end: collapsedColorOpacity)
            .animate(dragAnimationController);

    opacityAnimation = Tween(begin: expandedOpacity, end: collapsedOpacity)
        .animate(dragAnimationController);

    sliderTopCenterOpacityAnimation = Tween(
            begin: expandedSliderTopCenterOpacity,
            end: collapsedSliderTopCenterOpacity)
        .animate(dragAnimationController);

    sliderAnimationController = AnimationController(
      duration: Duration(seconds: 60),
      vsync: this,
    );
    sliderAnimationController.forward();

    sliderAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        sliderAnimationController.reverse();
        setState(() {
          _animationStatus = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        sliderAnimationController.forward();
        setState(() {
          _animationStatus = false;
        });
      }
    });

    sliderAnimationController.addListener(() {
      if (sliderAnimationController.value >= defaultSlidingValue) {
        if (_animationStatus) {
          if (sliderAnimationController.value <= currentSlidingValue) {
            if (this.mounted) {
              setState(() {
                currentSlidingValue = currentSlidingValue - defaultSlidingValue;

                randomSliderPositionsList.shuffle();

                int randomSlider = randomSliderPosition
                    .nextInt(randomSliderPositionsList.length - 1);

                mainSliderPageController.animateToPage(
                  randomSliderPositionsList[randomSlider],
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOutCubic,
                );
              });
            }
          }
        } else {
          if (sliderAnimationController.value > currentSlidingValue) {
            if (this.mounted) {
              setState(() {
                currentSlidingValue = currentSlidingValue + defaultSlidingValue;

                randomSliderPositionsList.shuffle();

                int randomSlider = randomSliderPosition
                    .nextInt(randomSliderPositionsList.length - 1);

                mainSliderPageController.animateToPage(
                  randomSliderPositionsList[randomSlider],
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOutCubic,
                );
              });
            }
          }
        }
      }
    });

    sliderEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    sliderEntryAnimationController.forward();

    sliderTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    sliderTextEntryAnimationController.forward();

    sliderTextEntryAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(sliderTextEntryAnimationController);

    mainPageTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    mainPageTextEntryAnimationController.forward();

    listItemEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    popularListItemTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    topRatedListItemTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    releasingTodayListItemTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    nowPlayingListItemTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    

    Timer(Duration(seconds: 4), () {
      this.fetchTopRatedItems();
    });

    Timer(Duration(seconds: 6), () {
      this.fetchReleasingTodayItems();
    });

    Timer(Duration(seconds: 8), () {
      this.fetchNowPlayingItems();
    });

    popularPageController = PageController();
    popularPageController.addListener(() {
      setState(() {
        popularCurrentPage = popularPageController.page;
      });
    });

    topRatedPageController = PageController();
    topRatedPageController.addListener(() {
      setState(() {
        topRatedCurrentPage = topRatedPageController.page;
      });
    });

    releasingTodayPageController = PageController();
    releasingTodayPageController.addListener(() {
      setState(() {
        releasingTodayCurrentPage = releasingTodayPageController.page;
      });
    });

    nowPlayingPageController = PageController();
    nowPlayingPageController.addListener(() {
      setState(() {
        nowPlayingCurrentPage = nowPlayingPageController.page;
      });
    });

    mainPageController = ScrollController();
    mainPageController.addListener(() {
      if (mainPageController.hasClients) {}
    });
  }

  @override
  void dispose() {
    dragAnimationController.dispose();
    sliderAnimationController.dispose();
    sliderEntryAnimationController.dispose();
    sliderTextEntryAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    return AnimatedBuilder(
      animation: sliderEntryAnimationController,
      builder: (context, widget) {
        return Scaffold(
          bottomNavigationBar: CustomCurvedNavigationBar(
            index: _currentIndex,
            buttonBackgroundColor: _bgColorList[_currentIndex],
            color: _bgColorList[_currentIndex],
            animationCurve: Curves.easeInOut,
            height: 60.0,
            items: iconList(25.0, Colors.white),
            onTap: (index) {
              if (this.mounted) {
                setState(() {
                  _currentIndex = index;

                  if (sliderItemDetailsList != null &&
                      sliderItemDetailsList.length > 0) {
                    if (_currentIndex == 0) {
                      customSliderItemDetailsList.clear();
                      customSliderItemDetailsList =
                          sliderItemDetailsList.sublist(0, endTvRange);
                      customSliderItemDetailsList.shuffle();
                    } else if (_currentIndex == 1) {
                      customSliderItemDetailsList.clear();
                      customSliderItemDetailsList = sliderItemDetailsList
                          .sublist(beginMovieRange, endMovieRange);
                      customSliderItemDetailsList.shuffle();
                    } else if (_currentIndex == 2) {
                      customSliderItemDetailsList.clear();
                      customSliderItemDetailsList = sliderItemDetailsList
                          .sublist(beginPersonRange, endPersonRange);
                      customSliderItemDetailsList.shuffle();
                    }
                  }
                });
              }

              if (tvShowNowPlayingList != null &&
                  tvShowNowPlayingList.length > 0) {
                tvShowNowPlayingList.shuffle();
              }
              if (tvShowReleasingTodayList != null &&
                  tvShowReleasingTodayList.length > 0) {
                tvShowReleasingTodayList.shuffle();
              }
              // if (tvShowPopularList != null && tvShowPopularList.length > 0) {
              //   tvShowPopularList.shuffle();
              // }
              if (tvShowTopRatedList != null && tvShowTopRatedList.length > 0) {
                tvShowTopRatedList.shuffle();
              }

              sliderEntryAnimationController.reset();
              sliderEntryAnimationController.forward();

              sliderTextEntryAnimationController.reset();
              sliderTextEntryAnimationController.forward();

              mainPageTextEntryAnimationController.reset();
              mainPageTextEntryAnimationController.forward();

              listItemEntryAnimationController.reset();
              listItemEntryAnimationController.forward();

              topRatedListItemTextEntryAnimationController.reset();
              topRatedListItemTextEntryAnimationController.forward();

              popularListItemTextEntryAnimationController.reset();
              popularListItemTextEntryAnimationController.forward();

              releasingTodayListItemTextEntryAnimationController.reset();
              releasingTodayListItemTextEntryAnimationController.forward();

              nowPlayingListItemTextEntryAnimationController.reset();
              nowPlayingListItemTextEntryAnimationController.forward();
            },
          ),
          body: Container(
            color: _bgColorList[_currentIndex],
            child: AnimatedBuilder(
              animation: dragAnimationController,
              builder: (context, widget) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: heightFactorAnimation.value,
                      child: customSliderItemDetailsList == null ||
                              customSliderItemDetailsList.length <= 0
                          ? iconList(
                              80.0,
                              Colors.white.withOpacity(opacityAnimation.value),
                            )[_currentIndex]
                          : PageView.builder(
                              physics: BouncingScrollPhysics(),
                              controller: mainSliderPageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentSliderIndex = index;
                                });
                                sliderTextEntryAnimationController.reset();
                                sliderTextEntryAnimationController.forward();
                              },
                              itemBuilder: (context, index) {
                                if (customSliderItemDetailsList[index]
                                            ["imageUrl"] ==
                                        null ||
                                    customSliderItemDetailsList[index]
                                            ["imageUrl"] ==
                                        "") {
                                  return iconList(
                                      80.0,
                                      Colors.white.withOpacity(opacityAnimation
                                          .value))[_currentIndex];
                                }
                                return AnimatedBuilder(
                                  animation: sliderEntryAnimationController,
                                  builder: (context, widget) {
                                    return buildMainSliderListItems(
                                      customSliderItemDetailsList[index],
                                      mainSliderCurrentPage,
                                      index,
                                    );
                                  },
                                );
                              },
                              itemCount: customSliderItemDetailsList.length,
                            ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: expandedHeightFactor - 0.01,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Icon(
                                Icons.menu,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 15.0,
                                bottom: 6.0,
                              ),
                              child: Text(
                                _tabBarTextList[_currentIndex],
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: "ConcertOne-Regular",
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 1.16 - heightFactorAnimation.value,
                      child: _currentSliderIndex == null ||
                              customSliderItemDetailsList == null ||
                              customSliderItemDetailsList.length <= 0
                          ? Container()
                          : AnimatedBuilder(
                              animation: sliderTextEntryAnimationController,
                              builder: (context, widget) {
                                return Opacity(
                                  opacity: sliderTextEntryAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(
                                              opacityAnimation.value),
                                          Colors.black.withOpacity(
                                            sliderTopCenterOpacityAnimation
                                                .value,
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: Opacity(
                                      opacity: opacityAnimation.value,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                              _currentSliderIndex == null
                                                  ? ""
                                                  : customSliderItemDetailsList[
                                                                      _currentSliderIndex]
                                                                  ["name"] ==
                                                              null ||
                                                          customSliderItemDetailsList[
                                                                      _currentSliderIndex]
                                                                  ["name"] ==
                                                              ""
                                                      ? ""
                                                      : customSliderItemDetailsList[
                                                              _currentSliderIndex]
                                                          ["name"],
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily:
                                                    "ConcertOne-Regular",
                                                color: Colors.white.withOpacity(
                                                    sliderTextEntryAnimation
                                                        .value),
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          _currentSliderIndex == null ||
                                                  customSliderItemDetailsList ==
                                                      null ||
                                                  customSliderItemDetailsList
                                                          .length <=
                                                      0
                                              ? Container()
                                              : Expanded(
                                                  child: Container(
                                                    width: screenWidth - 245,
                                                    margin:
                                                        EdgeInsets.all(10.0),
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (_currentSliderIndex ==
                                                            index) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              mainSliderPageController
                                                                  .animateToPage(
                                                                index,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                curve: Curves
                                                                    .easeInOutCubic,
                                                              );
                                                            },
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child:
                                                                  AnimatedContainer(
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        300),
                                                                height: 10.0,
                                                                width: 10.0,
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  left: 10.0,
                                                                  right: 10.0,
                                                                  top: 5.0,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .white,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .white,
                                                                        spreadRadius:
                                                                            1.0,
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              mainSliderPageController
                                                                  .animateToPage(
                                                                index,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                curve: Curves
                                                                    .easeInOutCubic,
                                                              );
                                                            },
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child:
                                                                  AnimatedContainer(
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        400),
                                                                height: 8.0,
                                                                width: 8.0,
                                                                margin: EdgeInsets
                                                                    .all(10.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border
                                                                      .all(
                                                                    width: 1.0,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      itemCount:
                                                          customSliderItemDetailsList
                                                              .length,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 1.05 - heightFactorAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                Radius.circular(cornerRadiusAnimation.value),
                            topRight:
                                Radius.circular(cornerRadiusAnimation.value),
                          ),
                        ),
                        child: buildMainPageItems(0),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildMainSliderListItems(Map<String, String> sliderDetails,
      double mainSliderCurrentPage, int index) {
    if (index == mainSliderCurrentPage.floor()) {
      return Container(
        transform: Matrix4.identity()
          ..setFromTranslationRotationScale(
            VectorMath64.Vector3(
              -screenWidth * (index - mainSliderCurrentPage),
              0.0,
              0.0,
            ),
            VectorMath64.Quaternion(
              0.0,
              0.0,
              0.0,
              0.0,
            ),
            VectorMath64.Vector3(
              1 - (mainSliderCurrentPage - index),
              1,
              1,
            ),
          ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              sliderDetails["imageUrl"],
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              _bgColorList[_currentIndex]
                  .withOpacity(colorOpacityAnimation.value),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Container(
          color: Colors.white
              .withOpacity(1 - sliderEntryAnimationController.value),
        ),
      );
    } else if (index == mainSliderCurrentPage.floor() + 1) {
      return Container(
        transform: Matrix4.identity()
          ..setEntry(3, 0, 0.006 * -(mainSliderCurrentPage - index)),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              sliderDetails["imageUrl"],
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              _bgColorList[_currentIndex]
                  .withOpacity(colorOpacityAnimation.value),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Container(
          color: Colors.white
              .withOpacity(1 - sliderEntryAnimationController.value),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              sliderDetails["imageUrl"],
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              _bgColorList[_currentIndex]
                  .withOpacity(colorOpacityAnimation.value),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Container(
          color: Colors.white
              .withOpacity(0.8 - sliderEntryAnimationController.value),
        ),
      );
    }
  }

  PageStorage buildMainPageItems(int currentPage) {
    var pageStorageList = List<PageStorage>();

    pageStorageList.add(
      PageStorage(
        bucket: storageBucket,
        child: NotificationListener(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollUpdateNotification) {
              if (scrollNotification.metrics.axis == Axis.vertical) {
                if (scrollNotification.metrics.pixels <
                    screenHeight -
                        scrollNotification.metrics.viewportDimension) {
                  double fractionalDragged =
                      scrollNotification.scrollDelta / screenHeight;
                  dragAnimationController.value =
                      dragAnimationController.value + (5 * fractionalDragged);
                }
              }
            }
          },
          child: ListView(
            key: PageStorageKey("index1"),
            controller: mainPageController,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  top: 15,
                  left: 10.0,
                  bottom: 10.0,
                  right: 15.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: mainPageTextEntryAnimationController,
                      builder: (context, wdiget) {
                        return Text(
                          "Most Popular",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 18,
                            fontFamily: 'ConcertOne-Regular',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            color: Colors.black.withOpacity(
                                mainPageTextEntryAnimationController.value),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "View more >",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 14,
                            fontFamily: 'ConcertOne-Regular',
                            fontWeight: FontWeight.w100,
                            color: Colors.white.withOpacity(0.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // tvShowPopularList == null || tvShowPopularList.length == 0
              //     ? Container(
              //         height: 200,
              //         color: Colors.transparent,
              //         child: Center(
              //           child: LoadingBarIndicator(
              //             numberOfBars: 5,
              //             colors: buildLoadingBarColors(),
              //             barSpacing: 5.0,
              //             beginTweenValue: 10.0,
              //             endTweenValue: 15.0,
              //           ),
              //         ),
              //       )
              //     :
              AnimatedBuilder(
                animation: listItemEntryAnimationController,
                builder: (context, widget) {
                  return Opacity(
                    opacity: listItemEntryAnimationController.value,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(
                            3,
                            0,
                            0.006 *
                                (1 - listItemEntryAnimationController.value)),
                      child: Transform.translate(
                        offset: Offset(
                            screenWidth *
                                (1 - listItemEntryAnimationController.value),
                            0.0),
                        child: Container(
                          height: 330,
                          color: Colors.transparent,
                          child: PageStorage(
                            bucket: storageBucket,
                            child: PagewiseListView(
                              key: PageStorageKey("index1_most_popular"),
                              pageSize: 20,
                              controller: popularPageController,
                              scrollDirection: Axis.horizontal,
                              physics: BouncingScrollPhysics(),
                              pageFuture: (currentPopularPage){
                                fetchPopularItems(currentPopularPage);
                              },
                              itemBuilder: (context,
                                  DefaultMainTvShowResultsModel
                                      tvShowPopularList,
                                  index) {
                                if (index == popularCurrentPage.floor()) {
                                  return Transform.scale(
                                    scale: (1.0 - (popularCurrentPage - index)),
                                    child: buildTvShowMainListItems(
                                      tvShowPopularList.backdrop_path,
                                      tvShowPopularList.name,
                                      tvShowPopularList.id,
                                      popularListItemTextEntryAnimationController,
                                    ),
                                  );
                                } else if (index ==
                                    popularCurrentPage.floor() + 1) {
                                  return Transform.scale(
                                    scale: (1.0 + (popularCurrentPage - index)),
                                    child: buildTvShowMainListItems(
                                      tvShowPopularList.backdrop_path,
                                      tvShowPopularList.name,
                                      tvShowPopularList.id,
                                      popularListItemTextEntryAnimationController,
                                    ),
                                  );
                                } else {
                                  return buildTvShowMainListItems(
                                    tvShowPopularList.backdrop_path,
                                    tvShowPopularList.name,
                                    tvShowPopularList.id,
                                    popularListItemTextEntryAnimationController,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Container(
                height: 1.0,
                margin: EdgeInsets.only(bottom: 10.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 15,
                  left: 10.0,
                  bottom: 10.0,
                  right: 15.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: mainPageTextEntryAnimationController,
                      builder: (context, wdiget) {
                        return Text(
                          "Top Rated",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 18,
                            fontFamily: 'ConcertOne-Regular',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            color: Colors.black.withOpacity(
                                mainPageTextEntryAnimationController.value),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "View more >",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 14,
                            fontFamily: 'ConcertOne-Regular',
                            fontWeight: FontWeight.w100,
                            color: Colors.white.withOpacity(0.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              tvShowTopRatedList == null || tvShowTopRatedList.length == 0
                  ? Container(
                      height: 200,
                      color: Colors.transparent,
                      child: Center(
                        child: LoadingBarIndicator(
                          numberOfBars: 5,
                          colors: buildLoadingBarColors(),
                          barSpacing: 5.0,
                          beginTweenValue: 10.0,
                          endTweenValue: 15.0,
                        ),
                      ),
                    )
                  : AnimatedBuilder(
                      animation: listItemEntryAnimationController,
                      builder: (context, widget) {
                        return Opacity(
                          opacity: listItemEntryAnimationController.value,
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(
                                  3,
                                  0,
                                  0.006 *
                                      (1 -
                                          listItemEntryAnimationController
                                              .value)),
                            child: Transform.translate(
                              offset: Offset(
                                  screenWidth *
                                      (1 -
                                          listItemEntryAnimationController
                                              .value),
                                  0.0),
                              child: Container(
                                height: 330,
                                color: Colors.transparent,
                                child: PageStorage(
                                  bucket: storageBucket,
                                  child: PageView.builder(
                                    key: PageStorageKey("index1_top_rated"),
                                    controller: topRatedPageController,
                                    scrollDirection: Axis.horizontal,
                                    physics: BouncingScrollPhysics(),
                                    onPageChanged: (index) {
                                      topRatedListItemTextEntryAnimationController
                                          .reset();
                                      topRatedListItemTextEntryAnimationController
                                          .forward();
                                    },
                                    itemBuilder: (context, index) {
                                      if (index ==
                                          topRatedCurrentPage.floor()) {
                                        return Transform.scale(
                                          scale: (1.0 -
                                              (topRatedCurrentPage - index)),
                                          child: buildTvShowMainListItems(
                                            tvShowTopRatedList[index]
                                                .backdrop_path,
                                            tvShowTopRatedList[index].name,
                                            tvShowTopRatedList[index].id,
                                            topRatedListItemTextEntryAnimationController,
                                          ),
                                        );
                                      } else if (index ==
                                          topRatedCurrentPage.floor() + 1) {
                                        return Transform.scale(
                                          scale: (1.0 +
                                              (topRatedCurrentPage - index)),
                                          child: buildTvShowMainListItems(
                                            tvShowTopRatedList[index]
                                                .backdrop_path,
                                            tvShowTopRatedList[index].name,
                                            tvShowTopRatedList[index].id,
                                            topRatedListItemTextEntryAnimationController,
                                          ),
                                        );
                                      } else {
                                        return buildTvShowMainListItems(
                                          tvShowTopRatedList[index]
                                              .backdrop_path,
                                          tvShowTopRatedList[index].name,
                                          tvShowTopRatedList[index].id,
                                          topRatedListItemTextEntryAnimationController,
                                        );
                                      }
                                    },
                                    itemCount: tvShowTopRatedList.length,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              Container(
                height: 1.0,
                margin: EdgeInsets.only(bottom: 10.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 15,
                  left: 10.0,
                  bottom: 10.0,
                  right: 15.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: mainPageTextEntryAnimationController,
                      builder: (context, wdiget) {
                        return Text(
                          "Releasing Today",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 18,
                            fontFamily: 'ConcertOne-Regular',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            color: Colors.black.withOpacity(
                                mainPageTextEntryAnimationController.value),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "View more >",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 14,
                            fontFamily: 'ConcertOne-Regular',
                            fontWeight: FontWeight.w100,
                            color: Colors.white.withOpacity(0.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              tvShowReleasingTodayList == null ||
                      tvShowReleasingTodayList.length == 0
                  ? Container(
                      height: 200,
                      color: Colors.white,
                      child: Center(
                        child: LoadingBarIndicator(
                          numberOfBars: 5,
                          colors: buildLoadingBarColors(),
                          barSpacing: 5.0,
                          beginTweenValue: 10.0,
                          endTweenValue: 15.0,
                        ),
                      ),
                    )
                  : AnimatedBuilder(
                      animation: listItemEntryAnimationController,
                      builder: (context, widget) {
                        return Opacity(
                          opacity: listItemEntryAnimationController.value,
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(
                                  3,
                                  0,
                                  0.006 *
                                      (1 -
                                          listItemEntryAnimationController
                                              .value)),
                            child: Transform.translate(
                              offset: Offset(
                                  screenWidth *
                                      (1 -
                                          listItemEntryAnimationController
                                              .value),
                                  0.0),
                              child: Container(
                                height: 330,
                                color: Colors.white,
                                child: PageStorage(
                                  bucket: storageBucket,
                                  child: PageView.builder(
                                    key: PageStorageKey(
                                        "index1_releasing_today"),
                                    controller: releasingTodayPageController,
                                    scrollDirection: Axis.horizontal,
                                    physics: BouncingScrollPhysics(),
                                    onPageChanged: (index) {
                                      releasingTodayListItemTextEntryAnimationController
                                          .reset();
                                      releasingTodayListItemTextEntryAnimationController
                                          .forward();
                                    },
                                    itemBuilder: (context, index) {
                                      if (index ==
                                          releasingTodayCurrentPage.floor()) {
                                        return Transform.scale(
                                          scale: (1.0 -
                                              (releasingTodayCurrentPage -
                                                  index)),
                                          child: buildTvShowMainListItems(
                                            tvShowReleasingTodayList[index]
                                                .backdrop_path,
                                            tvShowReleasingTodayList[index]
                                                .name,
                                            tvShowReleasingTodayList[index].id,
                                            releasingTodayListItemTextEntryAnimationController,
                                          ),
                                        );
                                      } else if (index ==
                                          releasingTodayCurrentPage.floor() +
                                              1) {
                                        return Transform.scale(
                                          scale: (1.0 +
                                              (releasingTodayCurrentPage -
                                                  index)),
                                          child: buildTvShowMainListItems(
                                            tvShowReleasingTodayList[index]
                                                .backdrop_path,
                                            tvShowReleasingTodayList[index]
                                                .name,
                                            tvShowReleasingTodayList[index].id,
                                            releasingTodayListItemTextEntryAnimationController,
                                          ),
                                        );
                                      } else {
                                        return buildTvShowMainListItems(
                                          tvShowReleasingTodayList[index]
                                              .backdrop_path,
                                          tvShowReleasingTodayList[index].name,
                                          tvShowReleasingTodayList[index].id,
                                          releasingTodayListItemTextEntryAnimationController,
                                        );
                                      }
                                    },
                                    itemCount: tvShowReleasingTodayList.length,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              Container(
                height: 1.0,
                margin: EdgeInsets.only(bottom: 10.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: 15,
                  left: 10.0,
                  bottom: 10.0,
                  right: 15.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: mainPageTextEntryAnimationController,
                      builder: (context, wdiget) {
                        return Text(
                          "Now Playing",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 18,
                            fontFamily: 'ConcertOne-Regular',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                            color: Colors.black.withOpacity(
                                mainPageTextEntryAnimationController.value),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "View more >",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 14,
                            fontFamily: 'ConcertOne-Regular',
                            fontWeight: FontWeight.w100,
                            color: Colors.white.withOpacity(0.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              tvShowNowPlayingList == null || tvShowNowPlayingList.length == 0
                  ? Container(
                      height: 200,
                      color: Colors.white,
                      child: Center(
                        child: LoadingBarIndicator(
                          numberOfBars: 5,
                          colors: buildLoadingBarColors(),
                          barSpacing: 5.0,
                          beginTweenValue: 10.0,
                          endTweenValue: 15.0,
                        ),
                      ),
                    )
                  : AnimatedBuilder(
                      animation: listItemEntryAnimationController,
                      builder: (context, widget) {
                        return Opacity(
                          opacity: listItemEntryAnimationController.value,
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(
                                  3,
                                  0,
                                  0.006 *
                                      (1 -
                                          listItemEntryAnimationController
                                              .value)),
                            child: Transform.translate(
                              offset: Offset(
                                  screenWidth *
                                      (1 -
                                          listItemEntryAnimationController
                                              .value),
                                  0.0),
                              child: Container(
                                height: 330,
                                color: Colors.white,
                                child: PageStorage(
                                  bucket: storageBucket,
                                  child: PageView.builder(
                                    key: PageStorageKey("index1_now_playing"),
                                    controller: nowPlayingPageController,
                                    scrollDirection: Axis.horizontal,
                                    physics: BouncingScrollPhysics(),
                                    onPageChanged: (index) {
                                      nowPlayingListItemTextEntryAnimationController
                                          .reset();
                                      nowPlayingListItemTextEntryAnimationController
                                          .forward();
                                    },
                                    itemBuilder: (context, index) {
                                      if (index ==
                                          nowPlayingCurrentPage.floor()) {
                                        return Transform.scale(
                                          scale: (1.0 -
                                              (nowPlayingCurrentPage - index)),
                                          child: buildTvShowMainListItems(
                                            tvShowNowPlayingList[index]
                                                .backdrop_path,
                                            tvShowNowPlayingList[index].name,
                                            tvShowNowPlayingList[index].id,
                                            nowPlayingListItemTextEntryAnimationController,
                                          ),
                                        );
                                      } else if (index ==
                                          nowPlayingCurrentPage.floor() + 1) {
                                        return Transform.scale(
                                          scale: (1.0 +
                                              (nowPlayingCurrentPage - index)),
                                          child: buildTvShowMainListItems(
                                            tvShowNowPlayingList[index]
                                                .backdrop_path,
                                            tvShowNowPlayingList[index].name,
                                            tvShowNowPlayingList[index].id,
                                            nowPlayingListItemTextEntryAnimationController,
                                          ),
                                        );
                                      } else {
                                        return buildTvShowMainListItems(
                                          tvShowNowPlayingList[index]
                                              .backdrop_path,
                                          tvShowNowPlayingList[index].name,
                                          tvShowNowPlayingList[index].id,
                                          nowPlayingListItemTextEntryAnimationController,
                                        );
                                      }
                                    },
                                    itemCount: tvShowNowPlayingList.length,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );

    return pageStorageList[currentPage];
  }

  Widget buildTvShowMainListItems(String imageUrl, String name, int id,
      AnimationController _animationController) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          NewPageTransition(
            widget: TvShowDetails(
              tvShowId: id,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          top: 10.0,
          left: 10.0,
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 300.0,
                width: screenWidth - 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      spreadRadius: 1.0,
                      blurRadius: 1.0,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: screenWidth,
                    margin: EdgeInsets.only(
                      right: 20.0,
                      left: 20.0,
                      bottom: 15.0,
                    ),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, wdiget) {
                        return Text(
                          name == null || name == "" ? "" : name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: "ConcertOne-Regular",
                            color: Colors.black
                                .withOpacity(_animationController.value),
                            fontSize: 18,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: Offset(9.0, 3.0),
                child: Container(
                  transform: Matrix4.identity()
                    ..setEntry(3, 0, 0.00033)
                    ..rotateX(pi / 5)
                    ..rotateZ(-0.001),
                  height: 300,
                  width: screenWidth - 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 5.0,
                        offset: Offset(7.0, 5.0),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    child: imageUrl == null || imageUrl == ""
                        ? Container(
                            color: Colors.grey,
                            child: Icon(
                              Icons.live_tv,
                              color: Colors.grey[100],
                              size: 80,
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
