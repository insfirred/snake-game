import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'no_scroll_glow.dart';
import 'tiles.dart';

class BoardView extends StatefulWidget {
  const BoardView({super.key});

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  List<int> snakePosition = [0, 1, 2];
  int foodPosition = 45;
  SnakeDirection snakeDirection = SnakeDirection.right;
  bool isGameStarted = false;
  int userScore = 0;

  _initGame() {
    isGameStarted = true;
    Timer.periodic(
      gameTimerDuration,
      (timer) {
        _moveSnake();
        _eatFood();
        if (_gameOver()) {
          isGameStarted = false;
          timer.cancel();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Game Over'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _restartGame();
                  },
                  child: const Text('Start Over'),
                ),
              ],
            ),
          );
        }
        setState(() {});
      },
    );
  }

  _moveSnake() {
    switch (snakeDirection) {
      case SnakeDirection.up:
        if (snakePosition.last < colSize) {
          snakePosition.add(snakePosition.last + ((rowSize - 1) * colSize));
        } else {
          snakePosition.add(snakePosition.last - colSize);
        }
        break;
      case SnakeDirection.left:
        if (snakePosition.last % colSize == 0) {
          snakePosition.add(snakePosition.last + colSize - 1);
        } else {
          snakePosition.add(snakePosition.last - 1);
        }
        break;
      case SnakeDirection.right:
        if (snakePosition.last % colSize == colSize - 1) {
          snakePosition.add(snakePosition.last - colSize + 1);
        } else {
          snakePosition.add(snakePosition.last + 1);
        }
        break;
      case SnakeDirection.down:
        if (snakePosition.last >= (colSize * (rowSize - 1))) {
          snakePosition.add(snakePosition.last - ((rowSize - 1) * colSize));
        } else {
          snakePosition.add(snakePosition.last + colSize);
        }
        break;
    }
  }

  _eatFood() {
    if (snakePosition.last == foodPosition) {
      // snake eating food
      userScore++;
      while (snakePosition.contains(foodPosition)) {
        foodPosition = Random().nextInt(rowSize * colSize);
      }
    } else {
      snakePosition.removeAt(0);
    }
  }

  bool _gameOver() {
    // creates a temporary list same as snakePosition without head
    List<int> tempSnake = snakePosition.sublist(0, snakePosition.length - 1);

    // checks if head is present in temporary list
    if (tempSnake.contains(snakePosition.last)) return true;
    return false;
    // in easy words, we are checking duplicate of head in snakePosition
  }

  _restartGame() {
    snakePosition = [0, 1, 2];
    foodPosition = 45;
    snakeDirection = SnakeDirection.right;
    userScore = 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKey: (value) {
            if (!isGameStarted) {
              _initGame();
            } else {
              if (value.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
                // arrow up key pressed
                if (snakeDirection != SnakeDirection.down) {
                  snakeDirection = SnakeDirection.up;
                }
              } else if (value.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                // arrow down key pressed
                if (snakeDirection != SnakeDirection.up) {
                  snakeDirection = SnakeDirection.down;
                }
              } else if (value.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
                // arrow left key pressed
                if (snakeDirection != SnakeDirection.right) {
                  snakeDirection = SnakeDirection.left;
                }
              } else if (value.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                // arrow right key pressed
                if (snakeDirection != SnakeDirection.left) {
                  snakeDirection = SnakeDirection.right;
                }
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            child: Center(
              child: SizedBox(
                width: screenWidth > 428 ? 428 : screenWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserScore(userScore: userScore),
                    Expanded(
                      flex: 3,
                      child: ScrollConfiguration(
                        behavior: NoScrollGlow(),
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            if (!isGameStarted) {
                              _initGame();
                            } else {
                              if (details.delta.dy > 0) {
                                // swiping down
                                if (snakeDirection != SnakeDirection.up) {
                                  snakeDirection = SnakeDirection.down;
                                }
                              } else if (details.delta.dy < 0) {
                                // swiping up
                                if (snakeDirection != SnakeDirection.down) {
                                  snakeDirection = SnakeDirection.up;
                                }
                              }
                            }
                          },
                          onHorizontalDragUpdate: (details) {
                            if (!isGameStarted) {
                              _initGame();
                            } else {
                              if (details.delta.dx > 0) {
                                // swiping right
                                if (snakeDirection != SnakeDirection.left) {
                                  snakeDirection = SnakeDirection.right;
                                }
                              } else if (details.delta.dx < 0) {
                                // swiping left
                                if (snakeDirection != SnakeDirection.right) {
                                  snakeDirection = SnakeDirection.left;
                                }
                              }
                            }
                          },
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: rowSize * colSize,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: colSize,
                            ),
                            itemBuilder: (context, index) {
                              if (snakePosition.last == index) {
                                return const SnakeHead();
                              } else if (snakePosition.contains(index)) {
                                return const SnakeTile();
                              } else if (foodPosition == index) {
                                return const FoodTile();
                              }
                              return const BlankTile();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserScore extends StatelessWidget {
  const UserScore({
    super.key,
    required this.userScore,
  });

  final int userScore;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        'Score: $userScore',
        style: const TextStyle(fontSize: 28),
      ),
    );
  }
}
