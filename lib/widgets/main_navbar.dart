import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MainNavBar extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainNavBar({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: child,

      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          top: 8.h,
          bottom: 8.h + MediaQuery.of(context).padding.bottom, // ✅ safe area
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8.r,
              offset: Offset(0, -3.h),
            ),
          ],
        ),

        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.transparent,
          elevation: 0,

          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,

          selectedFontSize: 12.sp,
          unselectedFontSize: 11.sp,

          iconSize: 22.sp,

          showUnselectedLabels: true,

          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 22.sp),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group, size: 22.sp),
              label: 'Workers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 22.sp),
              label: 'Profile',
            ),
          ],

          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/workerslist');
                break;
              case 2:
                context.go('/profile');
                break;
            }
          },
        ),
      ),
    );
  }
}
