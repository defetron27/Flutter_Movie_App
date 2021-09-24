import 'package:flutter/material.dart';

import './AnimatingBar.dart';

class LoadingBarIndicator extends StatefulWidget {
  final int numberOfBars;
  final double barSpacing;
  final List<Color> colors;
  final int milliseconds;
  final double beginTweenValue;
  final double endTweenValue;

  LoadingBarIndicator({
    @required this.numberOfBars,
    @required this.colors,
    this.barSpacing = 0.0,
    this.milliseconds = 250,
    this.beginTweenValue = 5.0,
    this.endTweenValue = 10.0,
  });

  _LoadingBarIndicatorState createState() => _LoadingBarIndicatorState(
        numberOfBars: this.numberOfBars,
        colors: this.colors,
        barSpacing: this.barSpacing,
        milliseconds: this.milliseconds,
        beginTweenValue: this.beginTweenValue,
        endTweenValue: this.endTweenValue,
      );
}

class _LoadingBarIndicatorState extends State<LoadingBarIndicator>
    with TickerProviderStateMixin {
  int numberOfBars;
  int milliseconds;
  double barSpacing;
  List<Color> colors;
  double beginTweenValue;
  double endTweenValue;
  List<AnimationController> controllers = new List<AnimationController>();
  List<Animation<double>> animations = new List<Animation<double>>();
  List<Widget> _widgets = new List<Widget>();

  _LoadingBarIndicatorState({
    this.numberOfBars,
    this.colors,
    this.barSpacing,
    this.milliseconds,
    this.beginTweenValue,
    this.endTweenValue,
  });

  initState() {
    super.initState();
    for (int i = 0; i < numberOfBars; i++) {
      _addAnimationControllers();
      _buildAnimations(i);
      _addListOfDots(i);
    }

    controllers[0].forward();
  }

  void _addAnimationControllers() {
    controllers.add(AnimationController(
        duration: Duration(milliseconds: milliseconds), vsync: this));
  }

  void _addListOfDots(int index) {
    _widgets.add(Padding(
      padding: EdgeInsets.only(right: barSpacing),
      child: AnimatingBar(
        animation: animations[index],
        color: colors[index],
      ),
    ));
  }

  void _buildAnimations(int index) {
    animations.add(
        Tween(begin: widget.beginTweenValue, end: widget.endTweenValue)
            .animate(controllers[index])
              ..addStatusListener((AnimationStatus status) {
                if (status == AnimationStatus.completed)
                  controllers[index].reverse();
                if (index == numberOfBars - 1 &&
                    status == AnimationStatus.dismissed) {
                  controllers[0].forward();
                }
                if (animations[index].value > widget.endTweenValue / 2 &&
                    index < numberOfBars - 1) {
                  controllers[index + 1].forward();
                }
              }));
  }

  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _widgets,
      ),
    );
  }

  dispose() {
    for (int i = 0; i < numberOfBars; i++) controllers[i].dispose();
    super.dispose();
  }
}
