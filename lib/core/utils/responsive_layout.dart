import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final bool isContentOnly;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.isContentOnly = false,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 700;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700 &&
      MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)) return child;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: child,
      ),
    );
  }
}
