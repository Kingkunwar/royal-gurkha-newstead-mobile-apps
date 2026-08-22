import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurantapp/app/custom_widgets/custom_textfield.dart';
import 'package:restaurantapp/app/custom_widgets/primary_button.dart';
import 'package:restaurantapp/app/custom_widgets/screen_padding.dart';
import 'package:restaurantapp/app/functions/input_validators.dart';
import 'package:restaurantapp/app/functions/navigation_functions.dart';
import 'package:restaurantapp/app/routes/app_routes.dart';
import 'package:restaurantapp/core/constants/app_colors.dart';
import 'package:restaurantapp/core/constants/app_constants.dart';
import 'package:restaurantapp/core/network/service_locator/service_locator.dart';
import 'package:restaurantapp/features/checkout/cubit/postal_code_handler_cubit.dart';
import 'package:restaurantapp/features/postal_code/bloc/search_postal_code_bloc.dart';

class EnterPostalCodeWidget extends StatefulWidget {
  const EnterPostalCodeWidget({super.key});

  @override
  State<EnterPostalCodeWidget> createState() => _EnterPostalCodeWidgetState();
}

class _EnterPostalCodeWidgetState extends State<EnterPostalCodeWidget> {
  final TextEditingController _postalCodeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedAddress = '';
  String deliveryCharge = '';

  bool everyThingIsSelected(SearchPostalCodeState state) {
    return selectedAddress.isNotEmpty && state is SearchSuccessState;
  }

  @override
  void dispose() {
    locator<SearchPostalCodeBloc>().add(ClearPostalCodeEvent());
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: BlocBuilder<SearchPostalCodeBloc, SearchPostalCodeState>(
        builder: (context, state) {
          return ScreenPadding(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24.h),
                  Container(
                    height: 56.w,
                    width: 56.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primaryColor,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    "Enter your postal code",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "We'll use this to find your delivery address",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _postalCodeController,
                          validator: InputValidators.requiredValidator,
                          onChanged: (val) {
                            locator<SearchPostalCodeBloc>().add(
                              SearchForPostalCodeEvent(
                                query: _postalCodeController.text,
                              ),
                            );
                          },
                          hintText: "Postal Code",
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Material(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.r),
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              locator<SearchPostalCodeBloc>().add(
                                SearchForPostalCodeEvent(
                                  query: _postalCodeController.text,
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Icon(
                              Icons.sync,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (state is SearchingPostalCodeState) ...{
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 3.h,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: LinearProgressIndicator(
                          color: AppColors.primaryColor,
                          backgroundColor:
                              AppColors.primaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  },
                  if (state is SearchFailureState) ...{
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              state.failure.message!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  },
                  if (state is SearchSuccessState) ...{
                    SizedBox(height: 16.h),
                    Text(
                      "Select your address",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownMenu<String>(
                        initialSelection: state.fetchedAddresses.first,
                        trailingIcon: const Icon(Icons.keyboard_arrow_down),
                        textStyle: Theme.of(context).textTheme.bodyLarge,
                        inputDecorationTheme: InputDecorationTheme(
                          filled: true,
                          fillColor: const Color(0xFFF4F6F9),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onSelected: (String? value) {
                          setState(() {
                            selectedAddress = value!;
                          });
                        },
                        dropdownMenuEntries: state.fetchedAddresses
                            .map<DropdownMenuEntry<String>>(
                          (String value) {
                            return DropdownMenuEntry<String>(
                              value: value,
                              label: value,
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    if (everyThingIsSelected(state)) ...{
                      SizedBox(height: 4.h),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            locator<SearchPostalCodeBloc>()
                                .add(ClearPostalCodeEvent());
                            setState(() {
                              selectedAddress = "";
                            });
                          },
                          icon: Icon(Icons.close, size: 16.sp),
                          label: const Text("Clear location"),
                        ),
                      ),
                    },
                  },
                  SizedBox(height: 18.h),
                  const Divider(),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18.sp,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            "If your address doesn't load, please tap the sync icon above.",
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  if (everyThingIsSelected(state) &&
                      selectedAddress != AppConstants.pleaseSelectAnAddress)
                    PrimaryButton(
                      buttonTitle: "Proceed",
                      onTap: () {
                        locator<PostalCodeHandlerCubit>().setPostalCode(
                          address: selectedAddress,
                          postalCode: _postalCodeController.text,
                          deliveryCharge: state is SearchSuccessState
                              ? state.deliveryCharge
                              : "0",
                        );
                        pushNamed(
                          context: context,
                          routeName: AppRoutes.selectItemScreen,
                          arguments: 0,
                        );
                      },
                    ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
