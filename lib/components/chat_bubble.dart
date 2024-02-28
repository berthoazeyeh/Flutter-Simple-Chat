import "package:flutter/material.dart";
import 'dart:ui' as ui;

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  const ChatBubble({super.key, required this.message, required this.isSender});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
    );

    // Création d'un TextPainter
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: message, style: textStyle),
      maxLines:
          1, // Assurez-vous de définir maxLines sur 1 pour mesurer correctement la largeur
      textDirection: ui.TextDirection.ltr,
    );

    // Configurer la taille du textePainter en fonction de la largeur maximale souhaitée
    textPainter.layout(maxWidth: double.infinity);

    // Récupérer la largeur mesurée
    double textWidth = textPainter.width;
    // print(textWidth);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: !isSender ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isSender ? 16.0 : 0.0),
          topRight: Radius.circular(isSender ? 0.0 : 16.0),
          bottomLeft: const Radius.circular(16.0),
          bottomRight: const Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      //  BoxDecoration(
      //     borderRadius: isSender
      //         ? const BorderRadius.only(
      //             bottomLeft: Radius.circular(8),
      //             topLeft: Radius.circular(8),
      //             topRight: Radius.circular(8),
      //             bottomRight: Radius.circular(-8))
      //         : const BorderRadius.only(
      //             bottomLeft: Radius.circular(-8),
      //             topLeft: Radius.circular(8),
      //             topRight: Radius.circular(8),
      //             bottomRight: Radius.circular(8)),
      //     color: isSender ? Colors.white : Colors.blue,
      //     border: isSender ? Border.all(color: Colors.black) : null),
      child: Container(
        width: textWidth > MediaQuery.of(context).size.width * 0.5
            ? MediaQuery.of(context).size.width * 0.5
            : textWidth,
        child: Text(
          message,
          style: TextStyle(fontSize: 16, color: isSender ? null : Colors.white),
          // overflow: TextOverflow.clip,
          softWrap: true,
        ),
      ),
    );
  }
}
