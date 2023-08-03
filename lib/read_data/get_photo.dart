import 'package:flutter/material.dart';

class GetPhoto extends StatelessWidget {
  final String imageUrl;

  GetPhoto({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          SizedBox(
            width: 80, // Set the desired width
            height: 80, // Set the desired height
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          )
        ],
    );
  }
}
