import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'drop_down.dart';

/// This is Common App textfiled class.
/// We use this widget for show drop-down for options
/*
The DropDownTextField class is a Flutter widget that displays a text field with a dropdown icon. When the dropdown icon is tapped, a modal bottom sheet is displayed with a list of options. The user can select one or more options from the list, depending on the value of the multiple parameter.

The DropDownTextField widget has a number of parameters that can be set to customize its behavior and appearance. For example, the textEditingController parameter is used to specify a TextEditingController that is used to manage the state of the text field, and the title parameter is used to specify a title for the text field. The hint parameter is used to specify a hint text for the text field, and the options parameter is used to specify the list of options to display in the dropdown.

The DropDownTextField widget also has a selectedOptions parameter that can be used to specify the initially selected options, and an onChanged callback function that is called whenever the selected options change. The multiple parameter can be set to true to enable multiple selection of options, or to false to enable single selection of options.
* */
class DropDownTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final Widget bottomSheetTitle;
  final String? title;
  final String hint;
  final Map<int, String> options;
  final List<int>? selectedOptions;
  final Function(List<int>?)? onChanged;
  final Function(bool isOpen)? onOpened;
  final double barrierOpacity;
  final bool multiple;
  // FormFieldValidator<T>? validator
  final FormFieldValidator<String>? validator;

  //optional parameters
  final String? submitTitle;
  // final FocusNode? focusNode;
  final InputDecoration decoration;
  final InputDecoration focusedDecoration;
  final TextCapitalization? textCapitalization;
  final TextInputAction? textInputAction;
  final bool? enable;
  final bool isRequired;
  final TextStyle? style;
  final TextStyle itemStyle;
  final TextStyle selectedItemStyle;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final int? maxLines;
  final int? minLines;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? primaryColor;

  /// [isSearchVisible] flag use to manage the search widget visibility
  /// by default it is [True] so widget will be visible.
  final bool isSearchVisible;

  final bool isReadOnly;

  const DropDownTextField({
    super.key,
    required this.textEditingController,
    this.title,
    required this.hint,
    required this.options,
    this.selectedOptions,
    this.onChanged,
    this.onOpened,
    this.multiple = false,
    required this.isReadOnly,
    required this.bottomSheetTitle,
    required this.itemStyle,
    required this.selectedItemStyle,
    required this.barrierOpacity,

    /// optional parameters
    this.submitTitle,
    // this.focusNode,
    this.validator,
    required this.decoration,
    required this.focusedDecoration,
    this.textCapitalization,
    this.textInputAction,
    this.enable,
    this.isRequired = false,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign,
    this.textAlignVertical,
    this.maxLines,
    this.minLines,
    this.isSearchVisible = true,
    this.backgroundColor,
    this.borderColor,
    this.primaryColor,
  });

  void openDropdown() {
    final DropDownTextFieldState? state =
        (key as GlobalKey?)?.currentState as DropDownTextFieldState?;
    state?.onTextFieldTap();
  }

  @override
  State<DropDownTextField> createState() => DropDownTextFieldState();
}

class DropDownTextFieldState extends State<DropDownTextField> {
  late final _focusNode = FocusNode();
  var _isFocused = false;
  // final TextEditingController _searchTextEditingController = TextEditingController();

  /// This is on text changed method which will display on city text field on changed.
  void onTextFieldTap() {
    if (!widget.isReadOnly && !_isFocused) {
      setState(() {
        _isFocused = true;
      });
    }
    if (widget.isReadOnly) {
      return;
    }
    _focusNode.unfocus();
    DropDownState(
      DropDown(
        bottomSheetTitle: widget.bottomSheetTitle,
        submitButtonChild: Text(
          widget.submitTitle ?? 'Done',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        options: widget.options,
        selectedOptions: widget.selectedOptions,
        selectedItems: (List<dynamic> selectedList) {
          widget.textEditingController.text =
              tmpImplode(widget.options, selectedList);
          widget.onChanged?.call(List<int>.from(selectedList));
        },
        enableMultipleSelection: widget.multiple,
        isSearchVisible: widget.isSearchVisible,
      ),
      itemStyle: widget.itemStyle,
      selectedItemStyle: widget.selectedItemStyle,
    ).showModal(
      context,
      (isOpened) {
        if (!isOpened) {
          _focusNode.requestFocus();
        }
        widget.onOpened?.call(isOpened);
      },
      widget.barrierOpacity,
    );
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && !widget.isReadOnly) {
      setState(() {
        _isFocused = false;
      });
    }
  }

  @override
  void initState() {
    _focusNode.addListener(_handleFocusChange);
    renewValue();
    super.initState();
  }

  @override
  void didUpdateWidget(DropDownTextField oldWidget) {
    if (oldWidget.selectedOptions != widget.selectedOptions) {
      renewValue();
    }
    super.didUpdateWidget(oldWidget);
  }

  void renewValue() {
    if (!['', null, false, 0].contains(widget.selectedOptions)) {
      widget.textEditingController.text =
          tmpImplode(widget.options, widget.selectedOptions!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.textEditingController,
          cursorColor: Colors.black,
          keyboardType: TextInputType.none,
          showCursor: false,
          readOnly: true,
          enabled: widget.enable ?? true,
          focusNode: _focusNode,
          onTap: () {
            onTextFieldTap();
          },
          // Optional
          validator: widget.validator,
          decoration: _isFocused ? widget.focusedDecoration : widget.decoration,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.none,
          textInputAction: widget.textInputAction,
          style: widget.style ??
              const TextStyle(height: 0.85, fontSize: 14.0), //initial
          strutStyle: widget.strutStyle,
          textDirection: widget.textDirection,
          textAlign: widget.textAlign ?? TextAlign.start,
          textAlignVertical: widget.textAlignVertical,
          maxLines: widget.maxLines ?? 1,
          minLines: widget.minLines,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  // Comma separated values of options
  String tmpImplode(Map<int, String> options, List<dynamic> tmpSelectedList) {
    Map<int, String> tmpOptions = Map<int, String>.from(options);

    tmpOptions.removeWhere((id, value) => !tmpSelectedList.contains(id));
    return tmpOptions.values.join(',');
  }
}
