import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurantapp/app/custom_widgets/screen_padding.dart';
import 'package:restaurantapp/app/functions/show_toast.dart';
import 'package:restaurantapp/features/cart/bloc/cart_bloc.dart';
import 'package:restaurantapp/features/cart/models/cart_item_model.dart';
import 'package:restaurantapp/features/cart/widgets/app_dropdown_widget.dart';
import 'package:restaurantapp/features/meal_deals/model/meal_deal_model.dart';
import 'package:restaurantapp/features/meal_deals/model/meal_deal_option.dart';

/// One required choice within a selector: the sequence of nodes the user has
/// picked so far, drilling down one dropdown per level (eg. "Popular Indian
/// Curry" -> "Masala" -> "Chicken Tikka Masala") until a leaf is reached.
class _Slot {
  List<MealDealNode> chain = [];
}

class MealDealPickerWidget extends StatefulWidget {
  final MealDealHolder mealDeal;

  const MealDealPickerWidget({
    super.key,
    required this.mealDeal,
  });

  @override
  State<MealDealPickerWidget> createState() => _MealDealPickerWidgetState();
}

class _MealDealPickerWidgetState extends State<MealDealPickerWidget> {
  late final List<MealDealItems> _selectors;
  final Map<int, List<_Slot>> _slots = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectors = widget.mealDeal.topLevelItems;
    for (final selector in _selectors) {
      final id = _selectorId(selector);
      final chooseUpTo =
          (selector.chooseUpTo == null || selector.chooseUpTo == 0)
              ? 1
              : selector.chooseUpTo!;
      final slots = List.generate(chooseUpTo, (_) => _Slot());

      final options = widget.mealDeal.topLevelOptionsFor(selector);
      if (options.length == 1 && widget.mealDeal.isLeaf(options.first)) {
        for (final slot in slots) {
          slot.chain = [options.first];
        }
      }
      _slots[id] = slots;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _basePrice => double.tryParse(widget.mealDeal.price ?? '') ?? 0;

  double get _extraPrice {
    double extra = 0;
    for (final slots in _slots.values) {
      for (final slot in slots) {
        for (final node in slot.chain) {
          extra += node.price;
        }
      }
    }
    return extra;
  }

  double get _totalPrice => _basePrice + _extraPrice;

  bool _isSlotComplete(_Slot slot) =>
      slot.chain.isNotEmpty && widget.mealDeal.isLeaf(slot.chain.last);

  bool get _isComplete {
    for (final slots in _slots.values) {
      for (final slot in slots) {
        if (!_isSlotComplete(slot)) {
          return false;
        }
      }
    }
    return true;
  }

  int _selectorId(MealDealItems selector) =>
      selector.id ?? _selectors.indexOf(selector);

  void _addToCart() {
    if (!_isComplete) {
      showErrorToast("Please select all required options.");
      return;
    }

    final lines = <String>[widget.mealDeal.title ?? ''];
    for (final selector in _selectors) {
      for (final slot in _slots[_selectorId(selector)]!) {
        lines.add(slot.chain.last.title);
      }
    }

    final title = lines.join('\n');
    final itemId =
        "mealdeal_${widget.mealDeal.id}_${lines.join(',').hashCode}";

    BlocProvider.of<CartBloc>(context).add(
      AddItemToCartEvent(
        cartItem: CartItemModel(
          itemId: itemId,
          price: _totalPrice.toStringAsFixed(2),
          title: title,
          categoryId: widget.mealDeal.id?.toString() ?? '',
          qty: 1,
          rate: _totalPrice.toStringAsFixed(2),
          note: _notesController.text.trim(),
          cartKind: "mealdeal",
          mealDealId: widget.mealDeal.id,
        ),
      ),
    );
    showToast("Item added to cart.");
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            ScreenPadding(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mealDeal.title ?? '',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Select required options below",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1F7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      "£${_basePrice.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFEDF1F7),
                      child: const Icon(Icons.close, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            ..._selectors.asMap().entries.expand(
                  (entry) => [
                    if (entry.key > 0)
                      Divider(height: 1, color: Colors.grey.shade300),
                    _buildSelector(entry.value),
                  ],
                ),
            Divider(height: 1, color: Colors.grey.shade300),
            ScreenPadding(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notes (optional)",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      maxLength: 255,
                      decoration: InputDecoration(
                        hintText: "Add any special requests here",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF4F6F9),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              color: const Color(0xFFFFF7E0),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFF8A6D3B)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Some items may include an extra charge. Increasing the quantity of these items will add to the total price.",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: const Color(0xFF8A6D3B),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFF4F6F9),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Base price",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.grey)),
                      Text(
                        "£${_basePrice.toStringAsFixed(2)}",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total", style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        "£${_totalPrice.toStringAsFixed(2)}",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            ScreenPadding(
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "Cancel",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.grey.shade700),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 14.h),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: Colors.white),
                    label: const Text(
                      "Add To Cart",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSelector(MealDealItems selector) {
    final id = _selectorId(selector);
    final slots = _slots[id]!;
    final chooseUpTo = slots.length;
    final selectedCount = slots.where(_isSlotComplete).length;
    final isComplete = selectedCount == chooseUpTo;

    return ScreenPadding(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isComplete ? Icons.check_circle : Icons.check_circle_outline,
                  size: 20.sp,
                  color: isComplete ? Colors.green : Colors.grey.shade400,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "${selector.title ?? ''} ",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Choose any $chooseUpTo",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF1F7),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "$selectedCount/$chooseUpTo selected",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ...List.generate(
              chooseUpTo,
              (slotIndex) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: _buildSlotChain(selector, slots[slotIndex]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renders one dropdown per level of [slot]'s chain, drilling down as long
  /// as the currently selected node still has children to pick from.
  ///
  /// Dropdown values are the *index* into the current options list rather
  /// than the [MealDealNode] itself: each level's options are re-parsed on
  /// every build (fresh node instances), and the source data isn't always
  /// well-formed enough to guarantee unique titles, so matching by node
  /// equality can find zero or multiple matches and trip Flutter's dropdown
  /// assertion. An index is always unambiguous.
  Widget _buildSlotChain(MealDealItems selector, _Slot slot) {
    final dropdowns = <Widget>[];
    List<MealDealNode> currentOptions =
        widget.mealDeal.topLevelOptionsFor(selector);
    int level = 0;

    while (true) {
      final chainNode = level < slot.chain.length ? slot.chain[level] : null;
      int? selectedIndex;
      if (chainNode != null) {
        final index =
            currentOptions.indexWhere((n) => n.title == chainNode.title);
        selectedIndex = index >= 0 ? index : null;
      }
      final options = currentOptions;
      dropdowns.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: AppDropdown<int>(
            items: List.generate(options.length, (i) => i),
            value: selectedIndex,
            hint: "Select an option",
            fillColor: const Color(0xFFF4F6F9),
            labelBuilder: (index) => options[index].title,
            onChanged: (index) {
              setState(() {
                final newChain = slot.chain.sublist(0, level);
                if (index != null) {
                  newChain.add(options[index]);
                }
                slot.chain = newChain;
              });
            },
          ),
        ),
      );

      if (selectedIndex == null) {
        break;
      }
      final selectedNode = options[selectedIndex];
      final children = widget.mealDeal.childrenOf(selectedNode);
      if (children.isEmpty) {
        break;
      }
      currentOptions = children;
      level++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dropdowns,
    );
  }
}
