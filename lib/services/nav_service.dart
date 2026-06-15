

import 'package:flutter/cupertino.dart';
import '../core/core_constants/colors.dart';
import '../core/core_constants/media.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/scan/scan_screen.dart';
import '../ui/screens/trip_history/trip_history.dart';
import '../ui/shared_widgets/nav_item.dart';

class NavService {

  //get the navigation items
  static List<NavItem> navigationItems({bool isSelected = false, String? userImage}) {
    return [
      NavItem(
          navData: Media.home,
          navLabel: "Home",
          itemColor: isSelected ? AppColors.purple : AppColors.textFieldHintColor),
      // NavItem(
      //     navData: Media.search,
      //     navLabel: "Search",
      //     itemColor: isSelected ? AppColors.purple : AppColors.textFieldHintColor),
      NavItem(
          navData: Media.scan,
          navLabel: "Scan",
          itemColor: isSelected ? AppColors.purple : AppColors.textFieldHintColor),
      NavItem(
          navData: Media.history,
          navLabel: "History",
          isProfile: true,
          itemColor: isSelected ? AppColors.purple : AppColors.textFieldHintColor),
      NavItem(
          navData: Media.profile,
          navLabel: "Profile",
          itemColor: isSelected ? AppColors.purple : AppColors.textFieldHintColor),

    ];
  }

  //get the widgets for the screens
  static Widget? selectedScreen(int currentIndex) {
    List<Widget?> screens = [
      const HomePage(),
      const ScanScreen(),
      const TripHistory(),
      const ProfileScreen()
    ];
    if (screens[currentIndex] != null) {
      return screens[currentIndex];
    }
    return null;
  }



}