import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurantapp/core/constants/app_colors.dart';
import 'package:restaurantapp/features/cart/screens/cart_screen.dart';

class SelectServiceTypePopup extends StatelessWidget {
  final bool isDeliveryEnabled;
  final bool isCollectionEnabled;
  const SelectServiceTypePopup({
    super.key,
    required this.isCollectionEnabled,
    required this.isDeliveryEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "How would you like to order?",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 4.h),
          Text(
            "Choose a service type to continue",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          SizedBox(height: 18.h),
          if (isDeliveryEnabled)
            _ServiceOptionTile(
              icon: Icons.delivery_dining_outlined,
              title: "Delivery",
              subtitle: "Get it delivered to your door",
              onTap: () => Navigator.of(context).pop(ServiceType.delivery),
            ),
          if (isDeliveryEnabled && isCollectionEnabled) SizedBox(height: 10.h),
          if (isCollectionEnabled)
            _ServiceOptionTile(
              icon: Icons.storefront_outlined,
              title: "Collection",
              subtitle: "Pick it up from the restaurant",
              onTap: () => Navigator.of(context).pop(ServiceType.collection),
            ),
        ],
      ),
    );
  }
}

class _ServiceOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ServiceOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              Container(
                height: 44.w,
                width: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
