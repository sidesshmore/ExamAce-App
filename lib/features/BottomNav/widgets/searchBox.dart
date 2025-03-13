import 'package:flutter/material.dart';
import 'package:examaceapp/constants.dart';

class SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;
  final VoidCallback onClear;
  final bool showClearButton;

  const SearchBox({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search...',
    required this.onClear,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);

    return Container(
      height: Globals.screenHeight * 0.05,
      decoration: BoxDecoration(
        color: Globals.customWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Globals.customGreyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: Globals.screenHeight * 0.016,
          color: Globals.customBlack,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: Globals.screenHeight * 0.01,
            horizontal: Globals.screenWidth * 0.03,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Globals.customGreyDark,
            fontSize: Globals.screenHeight * 0.016,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: Globals.screenHeight * 0.022,
            color: Globals.customGreyDark,
          ),
          suffixIcon: showClearButton && controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: Globals.screenHeight * 0.018,
                    color: Globals.customGreyDark,
                  ),
                  onPressed: () {
                    controller.clear();
                    onClear();
                  },
                  splashRadius: Globals.screenHeight * 0.02,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
