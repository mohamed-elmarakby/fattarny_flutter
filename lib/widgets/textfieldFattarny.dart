import 'package:flutter/material.dart';
import 'package:fattarny/theme.dart';

class FattarnyTextField extends StatelessWidget {
  final bool obsecure, errorFound;
  final String hint, label, errorMsg;
  final IconData iconNeeded;
  final TextInputType type;
  final TextEditingController control;
  FattarnyTextField(
      {this.errorMsg,
      this.errorFound = false,
      this.obsecure = false,
      this.hint,
      this.type,
      this.label,
      this.iconNeeded,
      this.control});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(),
        child: TextField(
          style: TextStyle(color: Colors.white),
          controller: control,
          cursorColor: basicTheme().accentColor,
          obscureText: obsecure,
          decoration: InputDecoration(
              labelText: label,
              labelStyle: basicTheme().textTheme.headline,
              border: OutlineInputBorder(),
              hintText: hint,
              errorStyle: TextStyle(color: Colors.white),
              errorText: errorFound ? errorMsg : '',
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: basicTheme().accentColor)),
              hintStyle: basicTheme().textTheme.headline,
              icon: Icon(iconNeeded, color: basicTheme().iconTheme.color)),
          keyboardType: type,
        ),
      ),
    );
  }
}
