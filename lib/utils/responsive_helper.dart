import 'package:flutter/material.dart';

/// Helper class for responsive design across different screen sizes
class ResponsiveHelper {
  final BuildContext context;
  late final double screenWidth;
  late final double screenHeight;
  late final double blockSizeHorizontal;
  late final double blockSizeVertical;

  ResponsiveHelper(this.context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }

  /// Get responsive font size based on screen width
  double fontSize(double size) {
    // Base size is for a 360px width screen
    return size * (screenWidth / 360);
  }

  /// Get responsive height based on percentage of screen height
  double height(double percentage) {
    return blockSizeVertical * percentage;
  }

  /// Get responsive width based on percentage of screen width
  double width(double percentage) {
    return blockSizeHorizontal * percentage;
  }

  /// Get responsive spacing
  double spacing(double baseSize) {
    return baseSize * (screenWidth / 360);
  }

  /// Get responsive icon size
  double iconSize(double baseSize) {
    return baseSize * (screenWidth / 360);
  }

  /// Check if device is a small phone (width < 360)
  bool get isSmallPhone => screenWidth < 360;

  /// Check if device is a phone (width < 600)
  bool get isPhone => screenWidth < 600;

  /// Check if device is a tablet (width >= 600)
  bool get isTablet => screenWidth >= 600;

  /// Check if device is in landscape
  bool get isLandscape => screenWidth > screenHeight;

  /// Get safe padding values
  EdgeInsets get safePadding {
    if (isSmallPhone) {
      return const EdgeInsets.all(8);
    } else if (isPhone) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  /// Get button height based on screen size
  double get buttonHeight {
    if (isSmallPhone) {
      return height(8); // ~8% of screen height
    } else if (isPhone) {
      return height(10); // ~10% of screen height
    } else {
      return 120; // Fixed for tablets
    }
  }

  /// Get emoji/icon display size
  double get emojiSize {
    if (isSmallPhone) {
      return fontSize(60);
    } else if (isPhone) {
      return fontSize(80);
    } else {
      return fontSize(120);
    }
  }

  /// Get title font size
  double get titleSize {
    if (isSmallPhone) {
      return fontSize(28);
    } else if (isPhone) {
      return fontSize(36);
    } else {
      return fontSize(48);
    }
  }

  /// Get subtitle font size
  double get subtitleSize {
    if (isSmallPhone) {
      return fontSize(14);
    } else if (isPhone) {
      return fontSize(18);
    } else {
      return fontSize(24);
    }
  }

  /// Get body text font size
  double get bodyTextSize {
    if (isSmallPhone) {
      return fontSize(12);
    } else if (isPhone) {
      return fontSize(16);
    } else {
      return fontSize(20);
    }
  }

  /// Get question text font size (for quizzes)
  double get questionTextSize {
    if (isSmallPhone) {
      return fontSize(20);
    } else if (isPhone) {
      return fontSize(28);
    } else {
      return fontSize(36);
    }
  }

  /// Get answer button text size
  double get answerTextSize {
    if (isSmallPhone) {
      return fontSize(18);
    } else if (isPhone) {
      return fontSize(24);
    } else {
      return fontSize(32);
    }
  }

  /// Get vertical spacing between elements
  double get verticalSpacing {
    if (isSmallPhone) {
      return spacing(8);
    } else if (isPhone) {
      return spacing(12);
    } else {
      return spacing(20);
    }
  }

  /// Get horizontal spacing between elements
  double get horizontalSpacing {
    if (isSmallPhone) {
      return spacing(8);
    } else if (isPhone) {
      return spacing(12);
    } else {
      return spacing(16);
    }
  }
}
