class MealDealNode {
  final String title;
  final double price;

  /// Options nested directly under this node via bracket syntax, eg. the
  /// `Chicken Gurkha`/`Lamb Gurkha` inside `Gurkha[Chicken Gurkha:0, Lamb
  /// Gurkha:0]`. Empty when this node has no inline sub-options of its own —
  /// it may still gain children dynamically if its title matches another
  /// meal deal item's title (see [MealDealHolder.itemWithTitle]).
  final List<MealDealNode> children;

  const MealDealNode({
    required this.title,
    this.price = 0,
    this.children = const [],
  });

  @override
  bool operator ==(Object other) =>
      other is MealDealNode && other.title == title && other.price == price;

  @override
  int get hashCode => Object.hash(title, price);
}

final RegExp _groupRegex = RegExp(r"([A-Za-z0-9()&'’.\- ]+?)\[([^\[\]]*)\]");
final RegExp _leafRegex = RegExp(r'^(.*):(-?\d+(?:\.\d+)?)\s*$');

/// Parses the pipe/bracket delimited `item` field of a [MealDealItems] entry
/// (eg. `"Gurkha[Chicken Gurkha:0, Lamb Gurkha:0],Rani Macha:0"`) into a list
/// of top-level [MealDealNode]s. A bracketed group becomes a node whose
/// `children` are its bracketed contents (parsed recursively); everything
/// else becomes a leaf node with no children.
List<MealDealNode> parseMealDealNodes(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return [];
  }

  final List<MealDealNode> nodes = [];
  String working = raw.replaceAll('\n', ' ');

  working = working.replaceAllMapped(_groupRegex, (match) {
    final name = match.group(1)!.trim();
    final inner = match.group(2) ?? '';
    if (name.isNotEmpty) {
      nodes.add(
        MealDealNode(
          title: name,
          children: parseMealDealNodes(inner),
        ),
      );
    }
    return ',';
  });

  for (final part in working.split(',')) {
    final leaf = _parseLeaf(part);
    if (leaf != null) {
      nodes.add(leaf);
    }
  }

  return nodes;
}

MealDealNode? _parseLeaf(String token) {
  final trimmed = token.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final match = _leafRegex.firstMatch(trimmed);
  if (match != null) {
    final title = match.group(1)!.trim();
    if (title.isEmpty) {
      return null;
    }
    return MealDealNode(
      title: title,
      price: double.tryParse(match.group(2)!) ?? 0,
    );
  }
  return MealDealNode(title: trimmed);
}
