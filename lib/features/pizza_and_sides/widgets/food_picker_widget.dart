import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurantapp/app/custom_widgets/screen_padding.dart';
import 'package:restaurantapp/core/constants/app_colors.dart';
import 'package:restaurantapp/features/indian_nepalese_food/model/indian_nepalese_food_model.dart';

class FoodPickerWidget extends StatelessWidget {
  final SubItem? item;
  final SubPrices? subPrices;
  final Function() onAddTapped;
  final bool hasMultipleItems;
  final IconData? newIcon;

  const FoodPickerWidget({
    super.key,
    required this.item,
    this.hasMultipleItems = false,
    this.subPrices,
    this.newIcon,
    required this.onAddTapped,
  });

  String get _title => item?.title != null && subPrices?.title == null
      ? item?.title ?? ""
      : "${subPrices?.title} ${item?.title}";

  String get _price => subPrices != null
      ? "£${subPrices!.price}"
      : item?.price != null
          ? "£${item!.price}"
          : '';

  IconData get _icon =>
      newIcon ?? (!hasMultipleItems ? Icons.menu : Icons.add);

  @override
  Widget build(BuildContext context) {
    final int hotLevel = item?.hotLevel ?? 0;
    final List<String> allergyAdvice = item?.allergyAdvice ?? [];

    return ScreenPadding(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (hotLevel > 0) ...[
                        SizedBox(width: 6.w),
                        Row(
                          children: List.generate(
                            hotLevel.clamp(0, 3),
                            (_) => Icon(
                              Icons.local_fire_department,
                              size: 14.sp,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (allergyAdvice.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      "Contains: ${allergyAdvice.join(', ')}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Text(
                    _price,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            InkWell(
              onTap: onAddTapped,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  _icon,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
