import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CircleCheckBox extends StatefulWidget {
  const CircleCheckBox({
    super.key,
    this.initialValue = false,
    required this.onChanged,
    this.size,
    this.activeColor,
    this.inactiveColor,
  });

  final bool initialValue;
  final ValueChanged<bool> onChanged;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  State<CircleCheckBox> createState() => _CircleCheckBoxState();
}

class _CircleCheckBoxState extends State<CircleCheckBox> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  void _toggle() {
    setState(() {
      _value = !_value;
    });
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    _value = widget.initialValue;
    final double boxSize = widget.size ?? 20.w;
    final Color active = widget.activeColor ?? Colors.green;
    final Color inactive = widget.inactiveColor ?? Colors.grey;

    return InkWell(
      borderRadius: BorderRadius.circular(boxSize / 2),
      onTap: _toggle,
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _value ? active : Colors.transparent,
          border: Border.all(color: _value ? active : inactive, width: 1.5),
        ),
        child: _value
            ? Icon(Icons.check, size: boxSize * 0.7, color: Colors.white)
            : null,
      ),
    );
  }
}
