import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/sleep_analysis_screen.dart';
import 'package:smart_baby_cradle/theme_provider.dart';

class SleepAnalysisItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;

    return Theme(
      data: currentTheme,
      child: Container(
        decoration: BoxDecoration(
          color: currentTheme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(),
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
                  width: constraints.maxWidth * 0.65,
                  child: Image.asset('assets/image/sleep_analysis.png'),
                ),
              ),
              const FittedBox(
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
            ],
          ),
        ),
      ),
    );
  }
}
