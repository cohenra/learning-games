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

    // Better text scale factor with limits
    // Base: 360px width = 1.0, scale gradually
    double baseWidth = 360.0;
    double rawScale = screenWidth / baseWidth;
    // Clamp between 0.85 and 1.3 for better control
    textScaleFactor = rawScale.clamp(0.85, 1.3);
  }

  /// Get responsive font size based on screen width (with better scaling)
  double fontSize(double size) {
    // Use square root for more gradual scaling
    double scaleFactor = sqrt(screenWidth / 360.0);
    // Clamp the scale factor to reasonable limits
    scaleFactor = scaleFactor.clamp(0.9, 1.4);
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
      return EdgeInsets.symmetric(horizontal: width(4), vertical: height(1));
    } else if (isPhone) {
      return EdgeInsets.symmetric(horizontal: width(5), vertical: height(1.5));
    } else {
      return EdgeInsets.symmetric(horizontal: width(6), vertical: height(2));
    }
  }

  /// Get button height based on screen size
  double get buttonHeight {
    if (isSmallPhone) {
      return height(9); // ~9% of screen height
    } else if (isPhone) {
      return height(10); // ~10% of screen height
    } else {
      return min(height(12), 100.0); // Max 100px for tablets
    }
  }

  /// Get emoji/icon display size
  double get emojiSize {
    if (isSmallPhone) {
      return fontSize(70);
    } else if (isPhone) {
      return fontSize(90);
    } else {
      return fontSize(100);
    }
  }

  /// Get title font size
  double get titleSize {
    if (isSmallPhone) {
      return fontSize(32);
    } else if (isPhone) {
      return fontSize(40);
    } else {
      return fontSize(48);
    }
  }

  /// Get subtitle font size
  double get subtitleSize {
    if (isSmallPhone) {
      return fontSize(16);
    } else if (isPhone) {
      return fontSize(20);
    } else {
      return fontSize(24);
    }
  }

  /// Get body text font size
  double get bodyTextSize {
    if (isSmallPhone) {
      return fontSize(14);
    } else if (isPhone) {
      return fontSize(16);
    } else {
      return fontSize(18);
    }
  }

  /// Get question text font size (for quizzes)
  double get questionTextSize {
    if (isSmallPhone) {
      return fontSize(24);
    } else if (isPhone) {
      return fontSize(28);
    } else {
      return fontSize(32);
    }
  }

  /// Get answer button text size
  double get answerTextSize {
    if (isSmallPhone) {
      return fontSize(22);
    } else if (isPhone) {
      return fontSize(26);
    } else {
      return fontSize(30);
    }
  }

  /// Get large number display size (for quiz answers)
  double get largeNumberSize {
    if (isSmallPhone) {
      return fontSize(48);
    } else if (isPhone) {
      return fontSize(56);
    } else {
      return fontSize(64);
    }
  }

  /// Get vertical spacing between elements
  double get verticalSpacing {
    if (isSmallPhone) {
      return height(1.5);
    } else if (isPhone) {
      return height(2);
    } else {
      return height(2.5);
    }
  }

  /// Get horizontal spacing between elements
  double get horizontalSpacing {
    if (isSmallPhone) {
      return width(2);
    } else if (isPhone) {
      return width(2.5);
    } else {
      return width(3);
    }
  }

  /// Get padding for content areas
  EdgeInsets get contentPadding {
    return EdgeInsets.symmetric(
      horizontal: width(5),
      vertical: height(2),
    );
  }

  /// Get aspect ratio for quiz answer buttons
  double get quizButtonAspectRatio {
    if (isSmallPhone) {
      return 4.5; // Slightly taller for small phones
    } else if (isPhone) {
      return 5.0; // Medium height
    } else {
      return 6.0; // Thinner for tablets
    }
  }
}
