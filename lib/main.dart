import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(CardMatchingGame());
}

class CardMatchingGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<bool> isFaceUp = List<bool>.filled(16, false); // Tracks whether each card is face-up
  List<bool> isMatched = List<bool>.filled(16, false); // Tracks whether a card is matched
  List<int> selectedCards = []; // Stores indices of currently face-up cards
  
  // Create pairs of card values (8 pairs)
  List<int> cardValues = List<int>.generate(8, (index) => index)..addAll(List<int>.generate(8, (index) => index));

  int matchedPairs = 0; // Tracks number of matched pairs
  int score = 0; // Player's score
  int timeTaken = 0; // Time taken to match pairs
  Timer? timer; // Timer object
  bool gameStarted = false; // Flag to check if game has started

  // Shuffle the card values for a new game
  void shuffleCards() {
    cardValues.shuffle(Random()); // Shuffle the card values using the default random generator
  }

  // Handle card flipping logic
  void flipCard(int index) {
    if (isFaceUp[index] || isMatched[index] || selectedCards.length == 2) {
      return; // Prevent flipping if card is already face-up, matched, or two cards are face-up
    }

    if (!gameStarted) {
      startTimer(); // Start the timer when the first card is flipped
      gameStarted = true;
    }

    setState(() {
      isFaceUp[index] = true;
      selectedCards.add(index);
    });

    // If two cards are face-up, check if they match
    if (selectedCards.length == 2) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          if (cardValues[selectedCards[0]] == cardValues[selectedCards[1]]) {
            // Cards match, keep them face-up and mark as matched
            isMatched[selectedCards[0]] = true;
            isMatched[selectedCards[1]] = true;
            matchedPairs++; // Increment matched pairs counter
            score += 10; // Earn points for a match
          } else {
            // Cards do not match, flip them back down
            isFaceUp[selectedCards[0]] = false;
            isFaceUp[selectedCards[1]] = false;
            score -= 5; // Deduct points for a mismatch
          }
          selectedCards.clear(); // Clear selected cards after checking
        });

        // Check for victory condition
        if (matchedPairs == cardValues.length ~/ 2) {
          stopTimer(); // Stop the timer when the game is won
          _showVictoryDialog(); // Display victory message
        }
      });
    }
  }

  // Start the timer
  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        timeTaken++; // Increment time taken each second
      });
    });
  }

  // Stop the timer
  void stopTimer() {
    timer?.cancel();
  }

  // Show victory dialog
  void _showVictoryDialog() {
    stopTimer(); // Ensure timer is stopped before showing the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Victory!'),
          content: Text('You matched all pairs!\nTime: $timeTaken seconds\nScore: $score'),
          actions: <Widget>[
            TextButton(
              child: Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame(); // Reset the game
              },
            ),
          ],
        );
      },
    );
  }

  // Reset the game
  void _resetGame() {
    setState(() {
      isFaceUp = List<bool>.filled(16, false);
      isMatched = List<bool>.filled(16, false);
      selectedCards.clear();
      matchedPairs = 0;
      score = 0;
      timeTaken = 0;
      gameStarted = false;
      shuffleCards(); // Shuffle the card values for a new game
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Matching Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $score', style: TextStyle(fontSize: 20)),
                Text('Time: $timeTaken seconds', style: TextStyle(fontSize: 20)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4x4 grid
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: isFaceUp.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      flipCard(index); // Flip card on tap
                    },
                    child: CardWidget(
                      index: index,
                      isFaceUp: isFaceUp[index], // Pass card state to the widget
                      isMatched: isMatched[index], // Pass matched state to the widget
                      cardValue: cardValues[index], // Pass the actual card value to the widget
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final int index;
  final bool isFaceUp;
  final bool isMatched;
  final int cardValue; // Card value to display

  const CardWidget({
    Key? key,
    required this.index,
    required this.isFaceUp,
    required this.isMatched,
    required this.cardValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300), // Animation duration of 300ms
      decoration: BoxDecoration(
        color: isMatched ? Colors.green : (isFaceUp ? Colors.red : Colors.blue), // Green if matched, red if face-up, blue if face-down
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: isFaceUp || isMatched ? 1.0 : 0.0, // Fade in content if face-up or matched
          child: Text(
            isFaceUp || isMatched ? cardValue.toString() : '', // Show card value for pairs
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
      margin: EdgeInsets.all(4.0),
    );
  }
}
