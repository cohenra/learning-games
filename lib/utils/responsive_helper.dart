import 'package:flutter/material.dart';
import 'dart:math';

/// Helper class for responsive design across different screen sizes
class ResponsiveHelper {
  final BuildContext context;
  late final double screenWidth;
  late final double screenHeight;
  late final double blockSizeHorizontal;
  late final double blockSizeVertical;
  late final double textScaleFactor;
  late final double safeBlockHorizontal;
  late final double safeBlockVertical;

  ResponsiveHelper(this.context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    // Calculate safe area
    final safePaddingHorizontal = mediaQuery.padding.left + mediaQuery.padding.right;
    final safePaddingVertical = mediaQuery.padding.top + mediaQuery.padding.bottom;
    safeBlockHorizontal = (screenWidth - safePaddingHorizontal) / 100;
    safeBlockVertical = (screenHeight - safePaddingVertical) / 100;

    // Conservative text scale factor
    double baseWidth = 360.0;
    double rawScale = screenWidth / baseWidth;
    // More conservative clamping
    textScaleFactor = rawScale.clamp(0.75, 1.15);
  }

  /// Get responsive font size (conservative for better fit)
  double fontSize(double size) {
    double scaleFactor = sqrt(screenWidth / 360.0);
    // More conservative for tablets
    if (isTablet) {
      scaleFactor = scaleFactor.clamp(0.85, 1.1);
    } else {
      scaleFactor = scaleFactor.clamp(0.8, 1.2);
    }
    return size * scaleFactor;
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
    return baseSize * textScaleFactor;
  }

  /// Get responsive icon size
  double iconSize(double baseSize) {
    return baseSize * textScaleFactor;
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
      return EdgeInsets.symmetric(horizontal: width(3), vertical: height(0.8));
    } else if (isPhone) {
      return EdgeInsets.symmetric(horizontal: width(4), vertical: height(1));
    } else {
      return EdgeInsets.symmetric(horizontal: width(4), vertical: height(1.5));
    }
  }

  /// Get button height based on screen size (MORE CONSERVATIVE)
  double get buttonHeight {
    if (isSmallPhone) {
      return height(8); // 8% of screen height
    } else if (isPhone) {
      return height(9); // 9% of screen height
    } else {
      // Tablets: much smaller to fit more on screen
      return min(height(7), 70.0); // Max 70px for tablets
    }
  }

  /// Get emoji/icon display size (SMALLER FOR TABLETS)
  double get emojiSize {
    if (isSmallPhone) {
      return fontSize(60);
    } else if (isPhone) {
      return fontSize(70);
    } else {
      return fontSize(80); // Smaller for tablets
    }
  }

  /// Get title font size (SMALLER FOR TABLETS)
  double get titleSize {
    if (isSmallPhone) {
      return fontSize(28);
    } else if (isPhone) {
      return fontSize(32);
    } else {
      return fontSize(36); // Smaller for tablets
    }
  }

  /// Get subtitle font size
  double get subtitleSize {
    if (isSmallPhone) {
      return fontSize(14);
    } else if (isPhone) {
      return fontSize(16);
    } else {
      return fontSize(18); // Smaller for tablets
    }
  }

  /// Get body text font size
  double get bodyTextSize {
    if (isSmallPhone) {
      return fontSize(12);
    } else if (isPhone) {
      return fontSize(14);
    } else {
      return fontSize(15); // Smaller for tablets
    }
  }

  /// Get question text font size (for quizzes) - CONSERVATIVE
  double get questionTextSize {
    if (isSmallPhone) {
      return fontSize(20);
    } else if (isPhone) {
      return fontSize(22);
    } else {
      return fontSize(24); // Smaller for tablets
    }
  }

  /// Get answer button text size - CONSERVATIVE
  double get answerTextSize {
    if (isSmallPhone) {
      return fontSize(18);
    } else if (isPhone) {
      return fontSize(20);
    } else {
      return fontSize(22); // Smaller for tablets
    }
  }

  /// Get large number display size (for quiz answers) - CONSERVATIVE
  double get largeNumberSize {
    if (isSmallPhone) {
      return fontSize(38);
    } else if (isPhone) {
      return fontSize(42);
    } else {
      return fontSize(44); // Much smaller for tablets
    }
  }

  /// Get vertical spacing between elements (TIGHTER FOR TABLETS)
  double get verticalSpacing {
    if (isSmallPhone) {
      return height(1.2);
    } else if (isPhone) {
      return height(1.5);
    } else {
      return height(1.2); // Tighter for tablets
    }
  }

  /// Get horizontal spacing between elements
  double get horizontalSpacing {
    if (isSmallPhone) {
      return width(1.5);
    } else if (isPhone) {
      return width(2);
    } else {
      return width(2);
    }
  }

  /// Get padding for content areas
  EdgeInsets get contentPadding {
    return EdgeInsets.symmetric(
      horizontal: width(4),
      vertical: height(1.5),
    );
  }

  /// Get aspect ratio for quiz answer buttons (BETTER FIT)
  double get quizButtonAspectRatio {
    if (isSmallPhone) {
      return 3.8; // Taller for small phones
    } else if (isPhone) {
      return 4.2; // Medium height
    } else {
      return 5.5; // Thinner for tablets but not too thin
    }
  }
}
