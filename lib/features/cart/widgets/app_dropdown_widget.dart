import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? value;
  final String Function(T item) labelBuilder;
  final void Function(T?) onChanged;
  final String? hint;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? fillColor;
  final String? Function(T?)? validator;
  final bool displayTitle;

  const AppDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.labelBuilder,
    required this.onChanged,
    this.hint,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.fillColor,
    this.validator,
    this.displayTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fillColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<T>(
            initialValue: value,
            borderRadius: BorderRadius.circular(6),
            isExpanded: true,
            hint: hint != null
                ? Text(
                    hint!,
                  )
                : null,
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 24,
            validator: validator,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.zero,
              // contentPadding: EdgeInsets.only(
              //   top: context.appSpacing.sm,
              //   bottom: context.appSpacing.sm,
              //   right: context.appSpacing.md,
              //   left: context.appSpacing.xs,
              // ),
            ),
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder(item),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
