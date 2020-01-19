// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';

enum _Element { background, text, shadow, image, opacity }

final _lightTheme = {
  _Element.background: Colors.transparent,
  _Element.text: Colors.white,
  _Element.shadow: Color(0x40000000),
  _Element.opacity: 1.0,
};

final _darkTheme = {
  _Element.background: Color(0x90000000),
  _Element.text: Color(0xFFffe0b2),
  _Element.shadow: Color(0x40000000),
  _Element.opacity: 0.8,
};

class ActiveEasteregg {
  ActiveEasteregg({
    this.easteregg,
    this.slideAnimation,
    this.wobbleAnimation,
  });

  Easteregg easteregg;
  Animation<Offset> slideAnimation;
  Animation<Offset> wobbleAnimation;
}

class Easteregg {
  const Easteregg({this.image, this.type, this.duration, this.size});

  final AssetImage image;
  final int
      type; // 0 = Wobble in air / 1 = In air / 2 = On ground / 3 = From corner to corner
  final int duration;
  final double size;
}

const List<Easteregg> _eastereggs = const <Easteregg>[
  const Easteregg(
      image: AssetImage('assets/satellite.png'),
      type: 1,
      duration: 30,
      size: 60),
  const Easteregg(
      image: AssetImage('assets/ufo.png'), type: 0, duration: 15, size: 70),
  const Easteregg(
      image: AssetImage('assets/hotair_balloon.png'),
      type: 0,
      duration: 30,
      size: 50),
  const Easteregg(
      image: AssetImage('assets/airplane.png'),
      type: 1,
      duration: 10,
      size: 50),
  const Easteregg(
      image: AssetImage('assets/spaceman.png'),
      type: 0,
      duration: 30,
      size: 50),
  const Easteregg(
      image: AssetImage('assets/helicopter.png'),
      type: 1,
      duration: 20,
      size: 50),
  const Easteregg(
      image: AssetImage('assets/balloon.png'), type: 0, duration: 30, size: 30),
  const Easteregg(
      image: AssetImage('assets/racecar.png'), type: 2, duration: 5, size: 30),
  const Easteregg(
      image: AssetImage('assets/tractor.png'), type: 2, duration: 30, size: 50),
  const Easteregg(
      image: AssetImage('assets/rocket.png'), type: 3, duration: 10, size: 120),
];

List<AnimationController> _animationControllers = [];
List<AnimationController> _weatherWidgetControllers = [];

List<Widget> _stars = [];

bool _isNight = false;

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock>
    with TickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  double maxWidth = 0;
  double maxHeight = 0;

  int _hourOne;
  int _hourTen;
  int _minuteOne;
  int _minuteTen;

  int _lastHourOne;
  int _lastHourTen;
  int _lastMinuteOne;
  int _lastMinuteTen;

  String _meridiem = 'a.m';

  Random rng = new Random();
  ActiveEasteregg _activeEasteregg;

  final Tween<double> turnsTween = Tween<double>(
    begin: 1,
    end: 2,
  );

  double _backgroundColor = 0.0;
  final Animatable<Color> _backgroundAnim = TweenSequence<Color>([
    TweenSequenceItem(
      weight: 20.0,
      tween: ConstantTween<Color>(Color(0xFF303039)),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(0xFF303039),
        end: Color(0xFF644B63),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(0xFF644B63),
        end: Color(0xFFA76478),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(0xFFA76478),
        end: Color(0xFFE38575),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(0xFFE38575),
        end: Color(0xFFde6092),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(0xFFde6092),
        end: Color(0xFF8b55d6),
      ),
    ),
    TweenSequenceItem(
      weight: 15.0,
      tween: ColorTween(
        begin: Color(0xFF8b55d6),
        end: Color(0xFF556bfc),
      ),
    ),
    TweenSequenceItem(
      weight: 10.0,
      tween: ColorTween(
        begin: Color(0xFF556bfc),
        end: Color(0xFF2478ff),
      ),
    ),
    TweenSequenceItem(
      weight: 20.0,
      tween: ConstantTween<Color>(Color(0xFF2478ff)),
    ),
    TweenSequenceItem(
      weight: 10.0,
      tween: ColorTween(
        begin: Color(0xFF2478ff),
        end: Color(0xFF556bfc),
      ),
    ),
    TweenSequenceItem(
      weight: 5.0,
      tween: ColorTween(
        begin: Color(0xFF556bfc),
        end: Color(0xFF8b55d6),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(0xFF8b55d6),
        end: Color(0xFFde6092),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(0xFFde6092),
        end: Color(0xFFE38575),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(0xFFE38575),
        end: Color(0xFFA76478),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(0xFFA76478),
        end: Color(0xFF644B63),
      ),
    ),
    TweenSequenceItem(
      weight: 1.0,
      tween: ColorTween(
        begin: Color(0xFF644B63),
        end: Color(0xFF303039),
      ),
    ),
    TweenSequenceItem(
      weight: 20.0,
      tween: ConstantTween<Color>(Color(0xFF303039)),
    ),
  ]);

  AnimationController _hourOneController;
  AnimationController _hourTenController;
  AnimationController _minuteOneController;
  AnimationController _minuteTenController;

  Animation<Offset> _hourOneAnimation;
  Animation<Offset> _hourTenAnimation;
  Animation<Offset> _minuteOneAnimation;
  Animation<Offset> _minuteTenAnimation;

  AnimationController _secondController;

  Widget _weatherWidget;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);

    _hourOneController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _hourOneAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _hourOneController,
      curve: Curves.bounceOut,
    ));
    _hourTenController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _hourTenAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _hourTenController,
      curve: Curves.bounceOut,
    ));

    _minuteOneController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _minuteOneAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _minuteOneController,
      curve: Curves.bounceOut,
    ));
    _minuteTenController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _minuteTenAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _minuteTenController,
      curve: Curves.bounceOut,
    ));

    _secondController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _hourOneController.forward();
    _hourTenController.forward();
    _minuteOneController.forward();
    _minuteTenController.forward();

    _dateTime = DateTime.now();

    int hour = _dateTime.hour;
    _hourOne = hour % 10;
    _hourTen = (hour ~/ 10) % 10;

    int minute = _dateTime.minute;
    _minuteOne = minute % 10;
    _minuteTen = (minute ~/ 10) % 10;

    _lastHourOne = _hourOne;
    _lastHourTen = _hourTen;
    _lastMinuteOne = _minuteOne;
    _lastMinuteTen = _minuteTen;

    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    _hourOneController.dispose();
    _hourTenController.dispose();
    _minuteOneController.dispose();
    _minuteTenController.dispose();
    for (var _controller in _animationControllers) _controller.dispose();
    for (var _controller in _weatherWidgetControllers) _controller.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _weatherWidget = _makeWeatherWidget();
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();

      // Update once per minute. If you want to update every second, use the
      // following code.
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );

      int hour = _dateTime.hour;
      int minute = _dateTime.minute;
      int second = _dateTime.second;

      if (!widget.model.is24HourFormat) {
        if (hour > 11)
          _meridiem = 'p.m';
        else
          _meridiem = 'a.m';

        if (hour > 12)
          hour -= 12;
        else if (hour < 1) hour += 12;
      } else
        _meridiem = '';

      _hourOne = hour % 10;
      _hourTen = (hour ~/ 10) % 10;

      _minuteOne = minute % 10;
      _minuteTen = (minute ~/ 10) % 10;

      if (_lastHourOne != _hourOne) {
        _lastHourOne = _hourOne;
        _hourOneController.reset();
        _hourOneController.forward();
      }
      if (_lastHourTen != _hourTen) {
        _lastHourTen = _hourTen;
        _hourTenController.reset();
        _hourTenController.forward();
      }
      if (_lastMinuteOne != _minuteOne) {
        _lastMinuteOne = _minuteOne;
        _minuteOneController.reset();
        _minuteOneController.forward();
      }
      if (_lastMinuteTen != _minuteTen) {
        _lastMinuteTen = _minuteTen;
        _minuteTenController.reset();
        _minuteTenController.forward();
      }

      _backgroundColor = (second + (minute * 60) + (hour * 60 * 60)) / 86400;

      if (_activeEasteregg == null && rng.nextInt(1000) == 1)
        _spawnEasteregg(_eastereggs[rng.nextInt(_eastereggs.length)]);

      if (hour > 19) {
        if (!_isNight) {
          _isNight = true;
          _weatherWidget = _makeWeatherWidget();
        }
      } else if (hour > 3) {
        if (_isNight) {
          _isNight = false;
          _weatherWidget = _makeWeatherWidget();
        }
      }

      if (_isNight) _spawnStar();
    });
  }

  Future _spawnStar() async {
    if (_stars.length > 20) return;

    AnimationController _scaleController;
    Animation<double> _scaleAnimation;

    _scaleController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );

    _animationControllers.add(_scaleController);

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _scaleController.forward();

    AnimationController _twinkleController;
    Animation<double> _twinkleAnimation;

    _twinkleController = AnimationController(
      duration: Duration(seconds: 1 + rng.nextInt(2)),
      vsync: this,
    )..repeat(reverse: true);

    _animationControllers.add(_twinkleController);

    _twinkleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _twinkleController,
      curve: Curves.easeInOut,
    ));

    Widget newStar = Positioned(
        top: rng.nextInt(maxHeight.toInt()).toDouble(),
        left: rng.nextInt(maxWidth.toInt()).toDouble(),
        child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
                opacity: _twinkleAnimation,
                child: Image(image: AssetImage('assets/star.png')))));

    _stars.add(newStar);

    await Future.delayed(Duration(seconds: 10 + rng.nextInt(10)));

    _scaleController.reverse();

    await Future.delayed(Duration(seconds: 5));

    _scaleController.dispose();
    _twinkleController.dispose();
    _animationControllers.remove(_scaleController);
    _animationControllers.remove(_twinkleController);
    _stars.remove(newStar);
  }

  void _spawnEasteregg(Easteregg easteregg) {
    AnimationController _slideController;
    Animation<Offset> _slideAnimation;

    _slideController = AnimationController(
      duration: Duration(seconds: easteregg.duration),
      vsync: this,
    );
    _slideController.forward();

    _animationControllers.add(_slideController);

    switch (easteregg.type) {
      case 0:
        AnimationController _wobbleController;
        Animation<Offset> _wobbleAnimation;
        _wobbleController = AnimationController(
          duration: const Duration(seconds: 2),
          vsync: this,
        )..repeat(reverse: true);

        _animationControllers.add(_wobbleController);

        _wobbleAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.0),
          end: Offset(0.0, 0.3),
        ).animate(CurvedAnimation(
          parent: _wobbleController,
          curve: Curves.easeInOut,
        ));

        _slideAnimation = Tween<Offset>(
          begin: const Offset(-0.5, 0.0),
          end: Offset(1.5, 0.0),
        ).animate(_slideController)
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _animationControllers.remove(_slideController);
              _animationControllers.remove(_wobbleController);
              _slideController.dispose();
              _wobbleController.dispose();

              _activeEasteregg = null;
            }
          });

        _activeEasteregg = new ActiveEasteregg(
          easteregg: easteregg,
          slideAnimation: _slideAnimation,
          wobbleAnimation: _wobbleAnimation,
        );
        break;
      case 1:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(-0.5, 0.0),
          end: Offset(1.5, 0.0),
        ).animate(_slideController)
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _animationControllers.remove(_slideController);
              _slideController.dispose();

              _activeEasteregg = null;
            }
          });

        _activeEasteregg = new ActiveEasteregg(
          easteregg: easteregg,
          slideAnimation: _slideAnimation,
        );
        break;
      case 2:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(-0.5, 0.0),
          end: Offset(1.5, 0.0),
        ).animate(_slideController)
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _animationControllers.remove(_slideController);
              _slideController.dispose();

              _activeEasteregg = null;
            }
          });

        _activeEasteregg = new ActiveEasteregg(
          easteregg: easteregg,
          slideAnimation: _slideAnimation,
        );
        break;
      case 3:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(-1, 1),
          end: Offset(1, -1),
        ).animate(_slideController)
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _animationControllers.remove(_slideController);
              _slideController.dispose();

              _activeEasteregg = null;
            }
          });

        _activeEasteregg = new ActiveEasteregg(
          easteregg: easteregg,
          slideAnimation: _slideAnimation,
        );
        break;
    }
  }

  Widget _makeEasteregg() {
    if (_activeEasteregg == null) return SizedBox.shrink();

    switch (_activeEasteregg.easteregg.type) {
      case 0:
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: SlideTransition(
            position: _activeEasteregg.slideAnimation,
            child: Row(
              children: <Widget>[
                SlideTransition(
                    position: _activeEasteregg.wobbleAnimation,
                    child: Image(
                        image: _activeEasteregg.easteregg.image,
                        height: _activeEasteregg.easteregg.size)),
              ],
            ),
          ),
        );
        break;
      case 1:
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: SlideTransition(
            position: _activeEasteregg.slideAnimation,
            child: Row(
              children: <Widget>[
                Image(
                    image: _activeEasteregg.easteregg.image,
                    height: _activeEasteregg.easteregg.size),
              ],
            ),
          ),
        );
        break;
      case 2:
        return Align(
          alignment: Alignment.bottomLeft,
          child: SlideTransition(
            position: _activeEasteregg.slideAnimation,
            child: Row(
              children: <Widget>[
                Image(
                    image: _activeEasteregg.easteregg.image,
                    height: _activeEasteregg.easteregg.size),
              ],
            ),
          ),
        );
        break;
      case 3:
        return SlideTransition(
          position: _activeEasteregg.slideAnimation,
          child: Container(
              alignment: Alignment.center,
              child: Image(
                  image: _activeEasteregg.easteregg.image,
                  height: _activeEasteregg.easteregg.size)),
        );
        break;
      default:
        return SizedBox.shrink();
    }
  }

  Widget _makeWeatherWidget() {
    //Remove old controllers
    for (var _controller in _weatherWidgetControllers) _controller.dispose();

    _weatherWidgetControllers.clear();

    switch (widget.model.weatherCondition) {
      case WeatherCondition.sunny:
        if (_isNight) {
          return SizedBox(
              width: 60,
              height: 60,
              child: Image(image: AssetImage('assets/moon.png')));
        } else {
          AnimationController _sunFlareScaleController;
          AnimationController _sunFlareRotationController1;
          AnimationController _sunFlareRotationController2;

          _sunFlareScaleController = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 6),
          )..repeat(reverse: true);

          _sunFlareRotationController1 = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 30),
          )..repeat();

          _sunFlareRotationController2 = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 40),
          )..repeat();

          _weatherWidgetControllers.add(_sunFlareScaleController);
          _weatherWidgetControllers.add(_sunFlareRotationController1);
          _weatherWidgetControllers.add(_sunFlareRotationController2);

          return SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: <Widget>[
                ScaleTransition(
                    scale: Tween(begin: 0.9, end: 1.05).animate(CurvedAnimation(
                      parent: _sunFlareScaleController,
                      curve: Curves.easeInOut,
                    )),
                    child: Center(
                        child: RotationTransition(
                            turns: Tween(begin: 0.0, end: 1.0)
                                .animate(_sunFlareRotationController1),
                            child: Image(
                                image: AssetImage('assets/sun_flare.png'))))),
                Center(
                    child: RotationTransition(
                        turns: Tween(begin: 0.0, end: -1.0)
                            .animate(_sunFlareRotationController2),
                        child:
                            Image(image: AssetImage('assets/sun_flare.png')))),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Center(
                      child: Image(
                    image: AssetImage('assets/sun_core.png'),
                    fit: BoxFit.fill,
                  )),
                ),
              ],
            ),
          );
        }
        break;
      case WeatherCondition.cloudy:
        AnimationController _cloudSlideController;

        _cloudSlideController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 5),
        )..repeat(reverse: true);

        _weatherWidgetControllers.add(_cloudSlideController);

        return SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.2, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _cloudSlideController,
                        curve: Curves.easeInOut,
                      )),
                      child: Image(image: AssetImage('assets/cloud.png'))),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: SlideTransition(
                      position: Tween<Offset>(
                        end: const Offset(0.2, 0.0),
                        begin: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _cloudSlideController,
                        curve: Curves.easeInOut,
                      )),
                      child: Image(image: AssetImage('assets/cloud.png'))),
                ),
              ),
            ],
          ),
        );
        break;
      case WeatherCondition.foggy:
        AnimationController _fogSlideController;

        _fogSlideController = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 8),
        )..repeat(reverse: true);

        _weatherWidgetControllers.add(_fogSlideController);

        return SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.2, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _fogSlideController,
                        curve: Curves.easeInOut,
                      )),
                      child: Image(image: AssetImage('assets/cloud_fog.png'))),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: SlideTransition(
                      position: Tween<Offset>(
                        end: const Offset(0.2, 0.0),
                        begin: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _fogSlideController,
                        curve: Curves.easeInOut,
                      )),
                      child: Image(
                        image: AssetImage('assets/fog.png'),
                        height: 30,
                      )),
                ),
              ),
            ],
          ),
        );
        break;
      case WeatherCondition.windy:
        return SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: <Widget>[
              _makeWind(0.0),
              _makeWind(40.0),
            ],
          ),
        );
        break;
      case WeatherCondition.snowy:
        return SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _makeSnowflake(),
                    _makeSnowflake(),
                    _makeSnowflake(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Image(image: AssetImage('assets/cloud_rain.png')),
              ),
            ],
          ),
        );
        break;
      case WeatherCondition.thunderstorm:
        AnimationController _thunderController;

        _thunderController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: rng.nextInt(2000)),
        )..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _thunderController.duration =
                  new Duration(milliseconds: rng.nextInt(2000));
              _thunderController.reset();
              _thunderController.forward();
            }
          });

        _thunderController.forward();

        _weatherWidgetControllers.add(_thunderController);

        return SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: Center(
                  child: FadeTransition(
                      opacity:
                          Tween(begin: 1.0, end: 0.1).animate(CurvedAnimation(
                        parent: _thunderController,
                        curve: Curves.easeInOutCubic,
                      )),
                      child: Image(
                        image: AssetImage('assets/lightning.png'),
                        height: 40,
                      )),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Image(image: AssetImage('assets/cloud_rain.png')),
              ),
            ],
          ),
        );
        break;
      case WeatherCondition.rainy:
        return SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            children: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _makeRaindrop(),
                    _makeRaindrop(),
                    _makeRaindrop(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Image(image: AssetImage('assets/cloud_rain.png')),
              ),
            ],
          ),
        );
        break;
      default:
        return SizedBox.shrink();
    }
  }

  Widget _makeWind(double top) {
    AnimationController _windController;

    _windController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000 + rng.nextInt(500)),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _windController.duration =
              new Duration(milliseconds: 1000 + rng.nextInt(500));
          _windController.reset();
          _windController.forward();
        }
      });

    _windController.forward();

    _weatherWidgetControllers.add(_windController);

    final Animation<double> _fadeAnim = TweenSequence<double>([
      TweenSequenceItem(
        weight: 1.0,
        tween: Tween(
          begin: 0.0,
          end: 0.9,
        ),
      ),
      TweenSequenceItem(weight: 3.0, tween: ConstantTween(0.9)),
      TweenSequenceItem(
        weight: 1.0,
        tween: Tween(
          begin: 0.9,
          end: 0.0,
        ),
      ),
    ]).animate(CurvedAnimation(
      parent: _windController,
      curve: Curves.easeInOut,
    ));

    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: top),
        child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: const Offset(1.0, 0.0),
            ).animate(_windController),
            child: FadeTransition(
                opacity: _fadeAnim,
                child: Image(
                  image: AssetImage('assets/wind.png'),
                  height: 30,
                ))),
      ),
    );
  }

  Widget _makeRaindrop() {
    AnimationController _raindropController;

    _raindropController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + rng.nextInt(300)),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _raindropController.duration =
              new Duration(milliseconds: 500 + rng.nextInt(300));
          _raindropController.reset();
          _raindropController.forward();
        }
      });

    _raindropController.forward();

    _weatherWidgetControllers.add(_raindropController);

    return SlideTransition(
        position: Tween<Offset>(
          end: Offset(0.0, 1.0),
          begin: Offset(0.0, -0.5),
        ).animate(_raindropController),
        child: FadeTransition(
            opacity: Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
              parent: _raindropController,
              curve: Curves.easeInExpo,
            )),
            child: Image(
              image: AssetImage('assets/raindrop.png'),
              height: 25,
            )));
  }

  Widget _makeSnowflake() {
    AnimationController _snowflakeController;
    AnimationController _rotationController;

    _snowflakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000 + rng.nextInt(1000)),
    )..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _snowflakeController.duration =
              new Duration(milliseconds: 2000 + rng.nextInt(1000));
          _snowflakeController.reset();
          _snowflakeController.forward();
        }
      });

    _snowflakeController.forward();

    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5 + rng.nextInt(5)),
    )..repeat();

    _weatherWidgetControllers.add(_snowflakeController);

    return SlideTransition(
        position: Tween<Offset>(
          end: Offset(0.0, 1.0),
          begin: Offset(0.0, -0.5),
        ).animate(_snowflakeController),
        child: RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_rotationController),
            child: FadeTransition(
                opacity: Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
                  parent: _snowflakeController,
                  curve: Curves.easeInExpo,
                )),
                child: Image(
                  image: AssetImage('assets/snowflake.png'),
                  height: 15,
                ))));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;

    maxWidth = MediaQuery.of(context).size.width;
    maxHeight = MediaQuery.of(context).size.height;

    final clockFontSize = maxWidth / 3.2;
    final clockMiddleFontSize = clockFontSize / 3;
    final temperatureFontSize = maxWidth / 30.0;

    final clockStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'SourceSansPro',
      fontSize: clockFontSize,
      shadows: [
        Shadow(
          blurRadius: 5,
          color: colors[_Element.shadow],
          offset: Offset(3, 0),
        ),
      ],
    );
    final clockMiddleStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'SourceSansPro',
      fontSize: clockMiddleFontSize,
      shadows: [
        Shadow(
          blurRadius: 5,
          color: colors[_Element.shadow],
          offset: Offset(3, 0),
        ),
      ],
    );
    final temperatureStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'SourceSansPro',
      fontSize: temperatureFontSize,
      shadows: [
        Shadow(
          blurRadius: 5,
          color: colors[_Element.shadow],
          offset: Offset(3, 0),
        ),
      ],
    );

    return Container(
      color: _backgroundAnim.evaluate(AlwaysStoppedAnimation(_backgroundColor)),
      child: Stack(
        children: <Widget>[
          Container(
            color: colors[_Element.background],
          ),
          for (var star in _stars) star,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Opacity(
                    opacity: colors[_Element.opacity],
                    child: _weatherWidget,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  DefaultTextStyle(
                      style: temperatureStyle,
                      child: Text(widget.model.temperatureString)),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: SlideTransition(
                  position: _hourTenAnimation,
                  child: Center(
                    child: DefaultTextStyle(
                        style: clockStyle, child: Text(_hourTen.toString())),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: SlideTransition(
                  position: _hourOneAnimation,
                  child: Center(
                    child: DefaultTextStyle(
                        style: clockStyle, child: Text(_hourOne.toString())),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: FadeTransition(
                  opacity: Tween(begin: 1.0, end: 0.4).animate(CurvedAnimation(
                    parent: _secondController,
                    curve: Curves.fastLinearToSlowEaseIn,
                  )),
                  child: Center(
                    child: DefaultTextStyle(
                        style: clockMiddleStyle, child: Text(':')),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: SlideTransition(
                  position: _minuteTenAnimation,
                  child: Center(
                    child: DefaultTextStyle(
                        style: clockStyle, child: Text(_minuteTen.toString())),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: SlideTransition(
                  position: _minuteOneAnimation,
                  child: Center(
                    child: DefaultTextStyle(
                        style: clockStyle, child: Text(_minuteOne.toString())),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: DefaultTextStyle(
                  style: clockMiddleStyle, child: Text(_meridiem)),
            ),
          ),
          _makeEasteregg()
        ],
      ),
    );
  }
}
