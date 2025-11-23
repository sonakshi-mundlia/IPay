import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onTap;

  const MicButton({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: isListening ? Colors.redAccent : Colors.blueAccent,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          key: ValueKey(isListening),
          size: 30,
        ),
      ),
    );
  }
}
