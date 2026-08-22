class CartItemHolder {
  CartItemModel item;
  int totalItemCount;

  CartItemHolder({
    required this.item,
    required this.totalItemCount,
  });

  CartItemHolder copyWith({
    CartItemModel? item,
    int? totalItemCount,
  }) {
    return CartItemHolder(
      item: item ?? this.item,
      totalItemCount: totalItemCount ?? this.totalItemCount,
    );
  }

  @override
  String toString() {
    return 'CartItemHolder(item: $item, totalItemCount: $totalItemCount)';
  }
}

class CartItemModel {
  String price;
  String title;
  String itemId;
  String categoryId;
  String rate;
  int qty;
  String? note;
  String? cartKind;
  int? mealDealId;

  CartItemModel({
    required this.price,
    required this.title,
    required this.itemId,
    required this.categoryId,
    required this.qty,
    required this.rate,
    this.note,
    this.cartKind,
    this.mealDealId,
  });

  @override
  String toString() {
    return 'CartItemModel('
        'price: $price, '
        'title: $title, '
        'itemId: $itemId, '
        'categoryId: $categoryId, '
        'rate: $rate, '
        'qty: $qty, '
        'note: $note, '
        'cartKind: $cartKind, '
        'mealDealId: $mealDealId'
        ')';
  }
}
