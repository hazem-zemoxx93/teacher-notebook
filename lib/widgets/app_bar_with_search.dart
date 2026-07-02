import 'package:flutter/material.dart';

class AppBarWithSearch extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSearch;
  final Function(String)? onSearchChanged;

  const AppBarWithSearch({
    Key? key,
    required this.title,
    this.onSearch,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  State<AppBarWithSearch> createState() => _AppBarWithSearchState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarWithSearchState extends State<AppBarWithSearch> {
  bool _isSearching = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'بحث...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: widget.onSearchChanged,
            )
          : Text(widget.title),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
          },
        ),
      ],
    );
  }
}
