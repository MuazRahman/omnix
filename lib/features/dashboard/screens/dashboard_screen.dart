import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omnix/core/theme/app_theme.dart';
import 'package:omnix/features/dashboard/controller/dash_board_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashBoardController controller = Get.put(DashBoardController());
    return Scaffold(

      body: Column(
        children: [

          // Appbar Header
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: .center,
                spacing: 20,
                children: [

                  // branch dropdown
                  DropdownButton2<String>(
                    valueListenable: controller.selectedBranch,
                    isDense: true,

                    // Dropdown options
                    items: controller.branches.map((String branch) {
                      final bool isSelected = branch == controller.selectedBranch.value;
                      return DropdownItem<String>(
                        value: branch,
                        child: Row(
                          mainAxisAlignment: .center,
                          spacing: 8,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: AppTheme.deepAmberWhite,
                            ),
                            Text(
                              branch,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: AppTheme.lightAmberWhite,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    onChanged: controller.branchOnChanged,

                    // Chevron icon (rotates when open)
                    iconStyleData: IconStyleData(
                      icon: Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: AppTheme.deepAmberWhite,
                        ),
                      ),
                      openMenuIcon: RotatedBox(
                        quarterTurns: 1,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: AppTheme.amber,
                        ),
                      ),
                      iconSize: 20,
                    ),

                    // Button decoration
                    buttonStyleData: ButtonStyleData(
                        height: 40,
                        width: 320,
                        padding: EdgeInsets.only(left: 16, right: 8),
                        overlayColor: WidgetStatePropertyAll(AppTheme.amber.withAlpha(20)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.amber.withAlpha(50), width: 0.5),
                          color: AppTheme.black,
                        )
                    ),

                    // Popup menu decoration
                    dropdownStyleData: DropdownStyleData(
                      width: 320,
                      maxHeight: 240,
                      elevation: 12,
                      offset: Offset(0, 4),
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.amber.withAlpha(50), width: 0.5),
                        borderRadius: BorderRadius.circular(6),
                        color: AppTheme.black,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(150),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                    ),

                    // Individual menu item styling
                    menuItemStyleData: MenuItemStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      borderRadius: BorderRadius.circular(4),
                      overlayColor: WidgetStatePropertyAll(AppTheme.amber.withAlpha(25)),
                      // Highlight the currently selected branch
                      selectedMenuItemBuilder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.amber.withAlpha(35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Expanded(child: child),
                        );
                      },
                    ),

                  ),

                  // search invoice
                  SizedBox(
                    height: 35,
                    width: 250,
                    child: TextField(
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          return newValue.copyWith(
                            text: newValue.text.toUpperCase(),
                            selection: newValue.selection
                          );
                          },
                        ),
                      ],
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.lightAmberWhite,
                        fontWeight: .w400,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.black,
                        prefixIcon: Icon(Icons.search_outlined, size: 19, color: AppTheme.deepAmberWhite.withValues(alpha: 50),),
                        hintText: 'Invoice (Ex: DHK-01-103)',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppTheme.lightAmberWhite.withValues(alpha: 120),
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppTheme.amber.withAlpha(50), width: 0.5),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppTheme.amber.withAlpha(50), width: 0.5),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: AppTheme.amber.withAlpha(50), width: 0.5),
                        ),
                      ),
                    ),
                  ),

                  // sync notification
                  Container(
                      height: 24,
                      width: 77.38,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.lightGreen, width: 0.5)
                      ),
                    
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 4,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.lightGreen,
                              maxRadius: 4,
                            ),
                            Text('SYNCED',
                              style: TextStyle(
                                color: AppTheme.lightGreen,
                                fontSize: 11,
                                fontWeight: .w600,

                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // new sale
                  Container(
                    height: 36,
                    width: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.amber,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 12,
                        children: [
                          DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.brown.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(Icons.add, color: AppTheme.deepAmberWhite, size: 16, fontWeight: FontWeight.w600,),
                              )),
                          Text('New Sale',
                            style: TextStyle(
                              color: AppTheme.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),
                  
                  // user
                  Column(
                    crossAxisAlignment: .end,
                    children: [
                      Text('Tanvir Rahman',
                        style: TextStyle(
                            color: AppTheme.lightAmberWhite,
                            fontSize: 15,
                          fontWeight: .w500
                        ),
                      ),
                      Text('Cashier',
                        style: TextStyle(
                            color: AppTheme.deepAmberWhite,
                            fontSize: 13,
                            fontWeight: .w500
                        ),
                      ),
                    ],
                  ),

                  
                  // user icon
                  DecoratedBox(
                    decoration: BoxDecoration(
                        color: AppTheme.lightAmberWhite,
                        borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(Icons.person, color: Colors.brown, size: 35,),
                  ),



                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
