import 'package:animate_do/animate_do.dart';
import 'package:ecom/shared/widgets/const/color_const.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Alignment logoAlignment = Alignment.centerLeft;

  @override
  void initState() {
    super.initState();

    // Delay to allow animation trigger
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        logoAlignment = Alignment.center;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedAlign(
            alignment: logoAlignment,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            child: Icon(
              Icons.shopping_cart_rounded,
              size: 200,
              color: ColorConst.accent,
            ),
          ),

          const SizedBox(height: 20),

          FadeInUpBig(
            animate: true,
            child: const Text(
              'Neo Mart',
              style: TextStyle(
                color: ColorConst.accent,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
