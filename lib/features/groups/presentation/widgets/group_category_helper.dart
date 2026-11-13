import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class GroupCategoryHelper {
  GroupCategoryHelper._();

  static const List<String> categories = [
    'Apartment',
    'Travel & Trip',
    'Sport & Clubs',
    'Friends & Dining',
    'Works & Project',
    'Other',
  ];

  static IconData getIcon(String category) {
    switch (category) {
      case 'Apartment':
        return LucideIcons.home;
      case 'Sport & Clubs':
        return LucideIcons.trophy;
      case 'Travel & Trip':
        return LucideIcons.plane;
      case 'Friends & Dining':
        return LucideIcons.utensils;
      case 'Works & Project':
        return LucideIcons.briefcase;
      case 'Other':
      default:
        return LucideIcons.layoutGrid;
    }
  }

  static Widget buildIcon(
    String category, {
    BuildContext? context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    final size = width ?? height ?? 24.0;
    final resolvedColor =
        color ?? context?.colors.topicColors(category).iconColor;
    return Icon(
      getIcon(category),
      size: size,
      color: resolvedColor,
    );
  }

  static Widget buildCategoryBadge(
    BuildContext context,
    String category, {
    double size = 48,
    double? iconSize,
    double borderRadius = 16,
    Border? border,
  }) {
    final topic = context.colors.topicColors(category);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: topic.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: topic.iconColor.withValues(alpha: 0.2),
            ),
      ),
      child: Icon(
        getIcon(category),
        size: iconSize ?? (size * 0.5),
        color: topic.iconColor,
      ),
    );
  }

  static String getLabel(String category, [BuildContext? context]) {
    final tr = context != null ? AppLocalizations.of(context) : null;
    return getLabelWithL10n(category, tr);
  }

  static String getLabelWithL10n(String category, [AppLocalizations? tr]) {
    if (tr != null) {
      switch (category) {
        case 'Apartment':
          return tr.groupCategoryApartment;
        case 'Sport & Clubs':
          return tr.groupCategorySport;
        case 'Travel & Trip':
          return tr.groupCategoryTravel;
        case 'Friends & Dining':
          return tr.groupCategoryDining;
        case 'Works & Project':
          return tr.groupCategoryWork;
        case 'Other':
        default:
          return tr.groupCategoryOther;
      }
    }
    // Fallback if no localization context is provided (e.g. non-UI tests)
    switch (category) {
      case 'Apartment':
        return 'Căn hộ & Phòng trọ';
      case 'Sport & Clubs':
        return 'Thể thao & CLB';
      case 'Travel & Trip':
        return 'Du lịch & Dã ngoại';
      case 'Friends & Dining':
        return 'Bạn bè & Ăn uống';
      case 'Works & Project':
        return 'Công việc & Dự án';
      case 'Other':
      default:
        return 'Khác';
    }
  }

  static String getShortLabel(String category, [BuildContext? context]) {
    final tr = context != null ? AppLocalizations.of(context) : null;
    return getShortLabelWithL10n(category, tr);
  }

  static String getShortLabelWithL10n(String category, [AppLocalizations? tr]) {
    if (tr != null) {
      switch (category) {
        case 'Apartment':
          return tr.groupCategoryApartmentShort;
        case 'Sport & Clubs':
          return tr.groupCategorySportShort;
        case 'Travel & Trip':
          return tr.groupCategoryTravelShort;
        case 'Friends & Dining':
          return tr.groupCategoryDiningShort;
        case 'Works & Project':
          return tr.groupCategoryWorkShort;
        case 'Other':
        default:
          return tr.groupCategoryOtherShort;
      }
    }
    // Fallback if no localization context is provided (e.g. non-UI tests)
    switch (category) {
      case 'Apartment':
        return 'Căn hộ chung';
      case 'Sport & Clubs':
        return 'Thể thao';
      case 'Travel & Trip':
        return 'Du lịch';
      case 'Friends & Dining':
        return 'Ăn uống';
      case 'Works & Project':
        return 'Công việc';
      case 'Other':
      default:
        return 'Khác';
    }
  }
}
