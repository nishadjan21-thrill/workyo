import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    setState(() {}); // update clear icon
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextField(
        controller: _controller,
        style: AppTextStyles.subtitle.copyWith(fontSize: 14.sp),
        onChanged: _onChanged,

        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 13.sp),

          filled: true,
          fillColor: Colors.grey[900],

          /// 🔍 PREFIX ICON
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.w),
            child: Icon(Icons.search, color: AppColors.primary, size: 20.sp),
          ),

          /// ❌ + FILTER ICONS
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Icon(
                      Icons.close,
                      color: AppColors.primary,
                      size: 18.sp,
                    ),
                  ),
                ),

              if (widget.onFilterPressed != null)
                IconButton(
                  onPressed: widget.onFilterPressed,
                  icon: Icon(
                    Icons.filter_list,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                ),
            ],
          ),

          contentPadding: EdgeInsets.symmetric(
            vertical: 14.h,
            horizontal: 12.w,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
