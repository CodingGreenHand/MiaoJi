import 'package:flutter/material.dart';

class StyleChangeableButton extends StatefulWidget {
  final ButtonStyle finalButtonStyle;
  final ButtonStyle? initialButtonStyle;
  final void Function()? onPressed;
  final Widget child;

  const StyleChangeableButton(
      {super.key,
      required this.finalButtonStyle,
      this.initialButtonStyle,
      required this.onPressed,
      required this.child});

  @override
  State<StyleChangeableButton> createState() => StyleChangeableButtonState();
}

class StyleChangeableButtonState extends State<StyleChangeableButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return !isPressed
        ? ElevatedButton(
            style: widget.initialButtonStyle,
            onPressed: () {
              widget.onPressed?.call();
              setState(() {
                isPressed = true;
              });
            },
            child: widget.child,
          )
        : ElevatedButton(
            style: widget.finalButtonStyle,
            onPressed: () {
              widget.onPressed?.call();
              setState(() {
                isPressed = false;
              });
            },
            child: widget.child,
          );
  }
}

class OptionSizedBox extends StatelessWidget{
  final Widget? child;

  const OptionSizedBox({super.key,this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: child
    );
  }
}