import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const PokemonMemoryApp());
}

class PokemonMemoryApp extends StatelessWidget {
  const PokemonMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon Memory Match',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const MemoryGamePage(),
    );
  }
}

class PokemonCard {
  final String name;
  final String imagePath;
  bool isFlipped;
  bool isMatched;

  PokemonCard({
    required this.name,
    required this.imagePath,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryGamePage extends StatefulWidget {
  const MemoryGamePage({super.key});

  @override
  State<MemoryGamePage> createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  static const int totalSeconds = 60;

  late List<PokemonCard> cards;
  Timer? timer;
  int remainingSeconds = totalSeconds;

  int moves = 0;

  int? firstSelectedIndex;
  int? secondSelectedIndex;

  bool isChecking = false;
  bool gameOver = false;
  bool gameWon = false;

  final List<Map<String, String>> pokemonData = [
    {
      'name': 'Pikachu',
      'image': 'assets/images/pikachu.png',
    },
    {
      'name': 'Charmander',
      'image': 'assets/images/charmander.png',
    },
    {
      'name': 'Squirtle',
      'image': 'assets/images/squirtle.png',
    },
    {
      'name': 'Bulbasaur',
      'image': 'assets/images/bulbasaur.png',
    },
    {
      'name': 'Eevee',
      'image': 'assets/images/eevee.png',
    },
    {
      'name': 'Snorlax',
      'image': 'assets/images/snorlax.png',
    },
    {
      'name': 'Jigglypuff',
      'image': 'assets/images/jigglypuff.png',
    },
    {
      'name': 'Meowth',
      'image': 'assets/images/meowth.png',
    },
    {
      'name': 'Psyduck',
      'image': 'assets/images/psyduck.png',
    },
    {
      'name': 'Gengar',
      'image': 'assets/images/gengar.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    startNewGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startNewGame() {
    timer?.cancel();

    final List<PokemonCard> generatedCards = [];

    for (final pokemon in pokemonData) {
      generatedCards.add(
        PokemonCard(
          name: pokemon['name']!,
          imagePath: pokemon['image']!,
        ),
      );

      generatedCards.add(
        PokemonCard(
          name: pokemon['name']!,
          imagePath: pokemon['image']!,
        ),
      );
    }

    generatedCards.shuffle(Random());

    setState(() {
      cards = generatedCards;
      remainingSeconds = totalSeconds;
      moves = 0;
      firstSelectedIndex = null;
      secondSelectedIndex = null;
      isChecking = false;
      gameOver = false;
      gameWon = false;
    });

    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          remainingSeconds = 0;
          gameOver = true;
          gameWon = false;
        });

        showEndDialog(
          title: 'Time is up!',
          message: 'You ran out of time. Try again!',
        );
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  void onCardTap(int index) {
    if (isChecking || gameOver) return;
    if (cards[index].isFlipped || cards[index].isMatched) return;

    setState(() {
      cards[index].isFlipped = true;

      if (firstSelectedIndex == null) {
        firstSelectedIndex = index;
      } else {
        secondSelectedIndex = index;
        moves++;
        isChecking = true;
      }
    });

    if (firstSelectedIndex != null && secondSelectedIndex != null) {
      checkMatch();
    }
  }

  void checkMatch() {
    final int firstIndex = firstSelectedIndex!;
    final int secondIndex = secondSelectedIndex!;

    if (cards[firstIndex].name == cards[secondIndex].name) {
      setState(() {
        cards[firstIndex].isMatched = true;
        cards[secondIndex].isMatched = true;

        firstSelectedIndex = null;
        secondSelectedIndex = null;
        isChecking = false;
      });

      checkWin();
    } else {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;

        setState(() {
          cards[firstIndex].isFlipped = false;
          cards[secondIndex].isFlipped = false;

          firstSelectedIndex = null;
          secondSelectedIndex = null;
          isChecking = false;
        });
      });
    }
  }

  void checkWin() {
    final bool allMatched = cards.every((card) => card.isMatched);

    if (allMatched) {
      timer?.cancel();

      setState(() {
        gameOver = true;
        gameWon = true;
      });

      showEndDialog(
        title: 'You Win!',
        message: 'Great job! You matched all Pokémon before time ran out.',
      );
    }
  }

  void showEndDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startNewGame();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  String formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int get matchedPairs {
    return cards.where((card) => card.isMatched).length ~/ 2;
  }

  @override
  Widget build(BuildContext context) {
    final bool warningTime = remainingSeconds <= 30;

    return Scaffold(
      backgroundColor: const Color(0xFF101020),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 430,
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1D2671),
                  Color(0xFFC33764),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  buildHeader(warningTime),
                  buildInfoPanel(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: GridView.builder(
                        itemCount: cards.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        itemBuilder: (context, index) {
                          return buildGameCard(index);
                        },
                      ),
                    ),
                  ),
                  buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader(bool warningTime) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Row(
        children: [
          const Icon(
            Icons.catching_pokemon,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Pokémon Memory Match',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: warningTime ? Colors.redAccent : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              formatTime(remainingSeconds),
              style: TextStyle(
                color: warningTime ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildInfoItem(
              icon: Icons.touch_app,
              label: 'Moves',
              value: '$moves',
            ),
            buildInfoItem(
              icon: Icons.favorite,
              label: 'Pairs',
              value: '$matchedPairs / 10',
            ),
            buildInfoItem(
              icon: Icons.timer,
              label: 'Limit',
              value: '1 min',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.redAccent,
          size: 26,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildGameCard(int index) {
    final PokemonCard card = cards[index];
    final bool showPokemon = card.isFlipped || card.isMatched;

    return GestureDetector(
      onTap: () => onCardTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: showPokemon
              ? const LinearGradient(
            colors: [
              Color(0xFFFFF9C4),
              Color(0xFFFFECB3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFCDD2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: card.isMatched ? Colors.greenAccent : Colors.white,
            width: card.isMatched ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: showPokemon
              ? buildPokemonFace(card)
              : buildPokeballBack(index),
        ),
      ),
    );
  }

  Widget buildPokeballBack(int index) {
    return Container(
      key: ValueKey('back-$index'),
      padding: const EdgeInsets.all(16),
      child: Image.asset(
        'assets/images/pokeball.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildPokemonFace(PokemonCard card) {
    return Container(
      key: ValueKey(card.name),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset(
              card.imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: startNewGame,
              icon: const Icon(Icons.refresh),
              label: const Text('Restart Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}