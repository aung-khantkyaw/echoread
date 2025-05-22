import 'package:flutter/material.dart';

class GifLoader extends StatelessWidget {
  const GifLoader({
    super.key,
    this.size = 200,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF4ED),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/image/loading.gif',
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              'Brewing your next story...',
              style: TextStyle(
                fontFamily: 'AncizarSerif',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
