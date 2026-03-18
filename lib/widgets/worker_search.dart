import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_textstyles.dart';
import '../theme/app_colors.dart';

typedef OnSearchChanged = void Function(String query);
typedef OnFilterPressed = void Function();

class WorkersSearchBar extends StatefulWidget {
  final OnSearchChanged onSearchChanged;
  final OnFilterPressed? onFilterPressed;
  final String hintText;

  const WorkersSearchBar({
    super.key,
    required this.onSearchChanged,
    this.onFilterPressed,
    this.hintText = "Search worker or job",
  });

  @override
  State<WorkersSearchBar> createState() => _WorkersSearchBarState();
}

class _WorkersSearchBarState extends State<WorkersSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearchChanged(value.trim());
    });
    setState(() {}); // Update clear icon visibility
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: AppTextStyles.subtitle,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: Colors.transparent,
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  widget.onSearchChanged('');
                  setState(() {});
                },
                child: const Icon(Icons.close, color: AppColors.primary),
              ),
            if (widget.onFilterPressed != null)
              IconButton(
                icon: const Icon(Icons.filter_list, color: AppColors.primary),
                onPressed: widget.onFilterPressed,
              ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}