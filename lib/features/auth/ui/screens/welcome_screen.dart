import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/hero_carousel.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header / Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                   const SizedBox(width: 20),
                   // Icon placeholder (simple circle 'i' from design)
                   Container(
                     padding: const EdgeInsets.all(5),
                     decoration: const BoxDecoration(
                       shape: BoxShape.circle,
                       color: Colors.black,
                     ),
                     child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                   ),
                   const Spacer(),
                   const Text(
                     "MentOr",
                     style: TextStyle(
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                       color: Colors.black,
                     ),
                   ),
                   const Spacer(),
                   const SizedBox(width: 45), // Balance the icon width
                ],
              ),
            ),
            
            // Carousel
            const Expanded(
              child: HeroCarousel(),
            ),

            const SizedBox(height: 30),

            // Buttons Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  CustomButton(
                    text: "Se connecter",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    type: ButtonType.primary,
                  ),
                  const SizedBox(height: 15),
                  CustomButton(
                    text: "S'inscrire",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    type: ButtonType.secondary,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // TODO: Continue as guest logic
                    },
                    child: const Text(
                      "Continuer en tant qu'invité",
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
