import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  static String getSvgPath(String category) {
    switch (category) {
      case 'Apartment':
        return 'assets/group_category_icons/department_icon.svg';
      case 'Sport & Clubs':
        return 'assets/group_category_icons/sport_icon.svg';
      case 'Travel & Trip':
        return 'assets/group_category_icons/travel_icon.svg';
      case 'Friends & Dining':
        return 'assets/group_category_icons/pizza_icon.svg';
      case 'Works & Project':
        return 'assets/group_category_icons/work_icon.svg';
      case 'Other':
      default:
        return 'assets/group_category_icons/other_icon.svg';
    }
  }

  static Widget buildIcon(
    String category, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      getSvgPath(category),
      width: width,
      height: height,
      fit: fit,
    );
  }

  static String getEmoji(String category) {
    switch (category) {
      case 'Apartment':
        return '🏢';
      case 'Sport & Clubs':
        return '🏸';
      case 'Travel & Trip':
        return '🏕️';
      case 'Friends & Dining':
        return '🍽️';
      case 'Works & Project':
        return '💼';
      case 'Other':
      default:
        return '👥';
    }
  }

  static String getLabel(String category) {
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

  static String getShortLabel(String category) {
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
