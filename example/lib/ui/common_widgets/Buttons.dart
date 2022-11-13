import 'package:flutter/material.dart';
import 'package:new_linux_plugin_example/utils/ColorConstant.dart';

ElevatedButton selectButton(String label, final void Function() func){
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary: AppColors.main_blue,
      padding: EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // <-- Radius
        ),
      ),
    onPressed: func,
    child: Text(label, style: TextStyle(fontSize: 20, color: AppColors.white))
  );
}

ElevatedButton confirmButton(String label, final void Function() func){
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: AppColors.main_red,
        padding: EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // <-- Radius
        ),
      ),
      onPressed: func,
      child: Text(label, style: TextStyle(fontSize: 16, color: AppColors.white))
  );
}

ElevatedButton unSelectedButton(String label, final void Function() func){
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: AppColors.gray,
        padding: EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // <-- Radius
        ),
      ),
      onPressed: func,
      child: Text(label, style: TextStyle(fontSize: 16, color: Colors.black))
  );
}

ElevatedButton selectedButton(String label, final void Function() func){
  return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: AppColors.main_blue,
        padding: EdgeInsets.all(5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // <-- Radius
        ),
      ),
      onPressed: func,
      child: Text(label, style: TextStyle(fontSize: 16, color: AppColors.white))
  );
}