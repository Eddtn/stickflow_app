import 'package:flutter/material.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchCtrl = TextEditingController();

  String _selectedCategory = 'All';

  final List<String> categories = ['All', 'Electronics', 'Food', 'Hardware'];

  final List<Map<String, String>> products = [
    {"name": "Laptop", "category": "Electronics"},
    {"name": "Rice", "category": "Food"},
    {"name": "Hammer", "category": "Hardware"},
    {"name": "Phone", "category": "Electronics"},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((p) {
      final matchSearch = p["name"]!.toLowerCase().contains(
        _searchCtrl.text.toLowerCase(),
      );

      final matchCategory =
          _selectedCategory == 'All' || p["category"] == _selectedCategory;

      return matchSearch && matchCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        title: const Text("Products"),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),

      body: Column(
        children: [
          // ─────────────────────────────
          // SEARCH BAR
          // ─────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ─────────────────────────────
          // CATEGORY FILTER
          // ─────────────────────────────
          Container(
            height: 44,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final selected = cat == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ─────────────────────────────
          // PRODUCT LIST
          // ─────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No products found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final product = filtered[i];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product["name"]!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(product["category"]!),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ─────────────────────────────
      // FAB
      // ─────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text("Add Product"),
      ),
    );
  }
}
