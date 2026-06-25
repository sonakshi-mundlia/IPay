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
      backgroundColor: isListening ? Colors.red : Colors.blue,
      onPressed: onTap,
      child: Icon(
        isListening ? Icons.mic_off : Icons.mic,
        color: Colors.white,
      ),
    );
  }
}
