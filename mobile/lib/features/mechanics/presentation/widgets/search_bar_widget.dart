import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {

  const SearchBarWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.onMicTap,
  });
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onMicTap;

  static const LinearGradient _orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.tacticalOrangeLight, AppColors.tacticalOrange],
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: BorderRadius.circular(27),
          border: Border.all(color: AppColors.clayDark, width: 1.2),
          boxShadow: AppColors.skeuRaised,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(
              Icons.search_rounded,
              color: AppColors.mutedLight,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkCharcoal,
                ),
                decoration: InputDecoration(
                  hintText: 'Search certified moto mechanics, BMW, KTM...',
                  hintStyle: AppTextStyles.bodySecondary.copyWith(
                    fontWeight: FontWeight.w400,
                    color: AppColors.mutedText,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: GestureDetector(
                onTap: onMicTap,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _orangeGradient,
                    boxShadow: AppColors.orangeGlow,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
