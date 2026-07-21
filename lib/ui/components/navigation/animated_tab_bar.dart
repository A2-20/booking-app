import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedTabItem {
  final IconData icon;
  final String label;

  AnimatedTabItem({required this.icon, required this.label});
}

class AnimatedTabBar extends StatefulWidget {
  final List<AnimatedTabItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;

  const AnimatedTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
  });

  @override
  State<AnimatedTabBar> createState() => _AnimatedTabBarState();
}

class _AnimatedTabBarState extends State<AnimatedTabBar> {
  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? Theme.of(context).primaryColor;
    final inactiveColor = widget.inactiveColor ?? Colors.grey;
    final backgroundColor = widget.backgroundColor ?? Colors.white;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // final double itemWidth = constraints.maxWidth / widget.items.length;

            return Stack(
              children: [
                // Moving Background Indicator
                // AnimatedPositionedDirectional(
                //   duration: const Duration(milliseconds: 400),
                //   curve: Curves.elasticOut,
                //   start: widget.currentIndex * itemWidth + (itemWidth / 2) - 25,
                //   top: 10,
                //   child: Container(
                //     width: 50,
                //     height: 50,
                //     decoration: BoxDecoration(
                //       color: activeColor.withOpacity(0.1),
                //       shape: BoxShape.circle,
                //     ),
                //   ),
                // ),
                // Tab Items
                Row(
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final isActive = widget.currentIndex == index;

                    return Expanded(
                      child: InkWell(
                        onTap: () => widget.onTap(index),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 300),
                                scale: isActive ? 1.2 : 1.0,
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  item.icon,
                                  color: isActive ? activeColor : inactiveColor,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isActive ? activeColor : inactiveColor,
                                ),
                                child: Text(item.label),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
