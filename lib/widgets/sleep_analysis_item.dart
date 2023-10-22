import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/sleep_analysis_screen.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class SleepAnalysisItem extends StatelessWidget {
  final bool isRaspberryPiOn; // New parameter

  SleepAnalysisItem({required this.isRaspberryPiOn}); // Constructor
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Theme(
      data: currentTheme,
      child: Container(
        decoration: BoxDecoration(
          color: currentTheme.colorScheme.inversePrimary,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 106, 106, 106)
                  .withOpacity(0.5), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset:
                  Offset(0, 3), // Offset in the positive direction of y-axis
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (ctx, constraints) => Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(SleepAnalysisScreen.routeName);
                },
                child: SizedBox(
                  child: Image.asset(
                    isRaspberryPiOn
                        ? 'assets/image/sleep_analysis.png'
                        : 'assets/image/sleep_dis.png',
                  ),
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.only(bottom: 5.0), // Add space below the text
                child: FittedBox(
                  child: Text(
                    'Sleep Analysis',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
