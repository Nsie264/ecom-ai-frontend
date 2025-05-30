class Category {
  final int id;
  final String name;
  final String? description;
  final List<Category>? children;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      children:
          json['children'] != null
              ? List<Category>.from(
                json['children'].map((x) => Category.fromJson(x)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'id': id, 'name': name};

    if (description != null) data['description'] = description;
    if (children != null) {
      data['children'] = children!.map((x) => x.toJson()).toList();
    }

    return data;
  }
}
