import 'package:flutter/material.dart';

import '../global/custom_colors.dart';
import 'package:badges/badges.dart' as badges;

class FilterIconWithBadge extends StatelessWidget {
  const FilterIconWithBadge({Key? key, required this.ontap, required this.number}) : super(key: key);

  final VoidCallback ontap;
  final int number;

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      position: badges.BadgePosition.topEnd(top: 0, end: 3),
      showBadge: number != 0,
      badgeAnimation: const badges.BadgeAnimation.slide(
        disappearanceFadeAnimationDuration: Duration(milliseconds: 200),
        curve: Curves.easeInCubic,
      ),
      badgeStyle: const badges.BadgeStyle(
        badgeColor: CustomColors.mint,
      ),
      badgeContent: Text(
        //pestStore.filterStore.numberFilters.toString(),
        number.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.filter_alt),
        onPressed: ontap,
        color: CustomColors.gay_pink,
      ),
    );
  }
}
