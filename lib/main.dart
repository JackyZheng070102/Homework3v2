import 'package:flutter/material.dart';
import 'dart:async';

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
  List<int> selectedCards = []; // Stores indices of currently face-up cards
  
  // Mock data for card matching (we'll match even and odd indices for simplicity)
  List<int> cardValues = List<int>.generate(16, (index) => index % 8); // Creates 8 pairs (0-7)

  // Handle card flipping logic
  void flipCard(int index) {
    if (isFaceUp[index] || selectedCards.length == 2) {
      return; // Prevent flipping if card is already face-up or two cards are face-up
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
            // Cards match, keep them face-up
          } else {
            // Cards do not match, flip them back
            isFaceUp[selectedCards[0]] = false;
            isFaceUp[selectedCards[1]] = false;
          }
          selectedCards.clear(); // Clear selected cards after checking
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Matching Game'),
      ),
      body: Padding(
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final int index;
  final bool isFaceUp;

  const CardWidget({Key? key, required this.index, required this.isFaceUp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300), // Animation duration of 300ms
      decoration: BoxDecoration(
        color: isFaceUp ? Colors.red : Colors.blue, // Red if face-up, blue if face-down
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: isFaceUp ? 1.0 : 0.0, // Fade in the content if face-up
          child: Text(
            'Card $index', // Placeholder text, replace with actual design later
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
