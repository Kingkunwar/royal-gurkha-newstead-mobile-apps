import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:restaurantapp/app/custom_widgets/custom_appbar.dart';
import 'package:restaurantapp/app/custom_widgets/screen_padding.dart';
import 'package:restaurantapp/app/functions/get_background_decoration.dart';
import 'package:restaurantapp/app/functions/navigation_functions.dart';
import 'package:restaurantapp/app/routes/app_routes.dart';
import 'package:restaurantapp/core/constants/app_colors.dart';
import 'package:restaurantapp/features/authentication/bloc/auth_bloc.dart';
import 'package:restaurantapp/features/profile/widgets/profile_logged_in_widget.dart';
import 'package:restaurantapp/features/profile/widgets/profile_not_logged_in_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Profile",
      ),
      body: Container(
        decoration: getBackgroundDecoration(),
        child: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          bool isLoggedIn = state is UserLoggedInState;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                if (isLoggedIn) ...{
                  const ProfileLoggedInWidget(),
                } else
                  const ProfileNotLoggedInWidget(),
                SizedBox(height: 20.h),
                if (isLoggedIn) ...{
                  const _ProfileSectionLabel(title: "Account"),
                  _ProfileMenuTile(
                    icon: Icons.history,
                    title: "My History",
                    onTap: () {
                      pushNamed(
                        context: context,
                        routeName: AppRoutes.userHistoryScreen,
                      );
                    },
                  ),
                  _ProfileMenuTile(
                    icon: Icons.password_rounded,
                    title: "Change password",
                    onTap: () {
                      pushNamed(
                        context: context,
                        routeName: AppRoutes.changePasswordScreen,
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                },
                const _ProfileSectionLabel(title: "Support"),
                _ProfileMenuTile(
                  icon: FontAwesomeIcons.info.data,
                  title: "Restaurant Info",
                  onTap: () {
                    pushNamed(
                      context: context,
                      routeName: AppRoutes.restaurantInfoScreen,
                    );
                  },
                ),
                _ProfileMenuTile(
                  icon: Icons.mail_outline,
                  title: "Contact us",
                  onTap: () {
                    pushNamed(
                      context: context,
                      routeName: AppRoutes.contactUsScreen,
                    );
                  },
                ),
                if (isLoggedIn) ...{
                  SizedBox(height: 16.h),
                  const _ProfileSectionLabel(title: "Danger zone"),
                  _ProfileMenuTile(
                    icon: Icons.delete_outline,
                    title: "Delete Account",
                    color: Colors.red,
                    onTap: () {
                      launchUrl(Uri.parse(
                          "https://docs.google.com/forms/d/e/1FAIpQLSdgU_LbJXwXyCZ36aDuDNmIMJw3Fk7MqF1eb8PuBD6UA3TxXw/viewform?usp=dialog"));
                    },
                  ),
                },
                SizedBox(height: 20.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _ProfileSectionLabel extends StatelessWidget {
  final String title;
  const _ProfileSectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return ScreenPadding(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color tileColor = color ?? AppColors.primaryColor;
    return ScreenPadding(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E5E5)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    height: 38.w,
                    width: 38.w,
                    decoration: BoxDecoration(
                      color: tileColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: tileColor, size: 18.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.sp,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
