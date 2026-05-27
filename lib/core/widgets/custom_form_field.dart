import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String text;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmit;
  final TextEditingController? controller;
  final TextInputType inputType;
  final double bottomPadding;
  final FocusNode? currentFocusNode;
  final bool isEnabled;
  final IconData? prefixIcon;
  final String? initText;
  final bool floatingLabel;
  final bool clearIcon;
  final void Function()? onClear;
  final Color? textColor;

  const CustomTextFormField({
    super.key,
    required this.text,
    this.isPassword = false,
    this.validator,
    this.onSubmit,
    this.controller,
    this.inputType = TextInputType.text,
    this.bottomPadding = 10.0,
    this.currentFocusNode,
    this.isEnabled = true,
    this.prefixIcon,
    this.clearIcon = false,
    this.initText,
    this.onClear,
    this.floatingLabel = true,  this.textColor,
  });

  @override
  CustomTextFormFieldState createState() => CustomTextFormFieldState();
}

class CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;
  Color _activeBorderColor = const Color(0xffEBEDEC);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      child: TextFormField(
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
        initialValue: widget.initText,
        focusNode: widget.currentFocusNode,
        enabled: widget.isEnabled,
        onFieldSubmitted: widget.onSubmit,
        keyboardType: widget.inputType,
        obscureText: widget.isPassword ? _obscureText : false,
        validator: widget.validator,
        controller: widget.controller,
        onChanged: (val) {
          setState(() {
            _activeBorderColor = val.isNotEmpty ? const Color(0xff5AC268) : const Color(0xffEBEDEC);
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: widget.text,
          floatingLabelBehavior: widget.floatingLabel
              ? FloatingLabelBehavior.auto // Do not float the label
              : FloatingLabelBehavior.never, // Default behavior
          floatingLabelStyle:  TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: widget.textColor??const Color(0xff37474F),
          ),
          labelStyle: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          enabledBorder: _buildBorder(_activeBorderColor),
          focusedBorder: _buildBorder( Colors.indigo),
          errorBorder: _buildBorder(Colors.red),
          focusedErrorBorder: _buildBorder(Colors.red),
          disabledBorder: _buildBorder(_activeBorderColor),
          suffixIcon: widget.isPassword
              ? IconButton(
            icon: Icon(!_obscureText ? Icons.remove_red_eye : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : widget.clearIcon?IconButton(
            icon: Icon(widget.controller!.text.isNotEmpty ? Icons.highlight_remove_rounded : null),
            onPressed: () {
              widget.controller!.clear();
              widget.onClear!();
            },
          ):null,
        ),
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: 2.0),
    );
  }
}
