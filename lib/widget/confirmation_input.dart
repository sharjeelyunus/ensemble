import 'package:ensemble/framework/action.dart';
import 'package:ensemble/screen_controller.dart';
import 'package:ensemble/util/utils.dart';
import 'package:ensemble/framework/widget/widget.dart' as framework;
import 'package:ensemble/widget/helpers/controllers.dart';
import 'package:ensemble/widget/helpers/widgets.dart';
import 'package:ensemble/widget/input/form_textfield.dart';
import 'package:flutter/material.dart';
import 'package:ensemble_ts_interpreter/invokables/invokable.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

class ConfirmationInput extends StatefulWidget
    with
        Invokable,
        HasController<ConfirmationInputController, ConfirmationInputState> {
  static const type = 'ConfirmationInput';
  ConfirmationInput({Key? key}) : super(key: key);

  final ConfirmationInputController _controller = ConfirmationInputController();
  @override
  ConfirmationInputController get controller => _controller;

  @override
  Map<String, Function> getters() {
    return {
      'text': () => _controller.text,
    };
  }

  @override
  Map<String, Function> setters() {
    return {
      'fieldType': (input) =>
          _controller.fieldType = Utils.optionalString(input),
      'inputType': (type) => _controller.inputType = Utils.optionalString(type),
      'autoComplete': (newValue) =>
          _controller.autoComplete = Utils.getBool(newValue, fallback: true),
      'enableCursor': (newValue) =>
          _controller.enableCursor = Utils.getBool(newValue, fallback: true),
      'length': (newValue) =>
          _controller.length = Utils.getInt(newValue, fallback: 4),
      'textStyle': (style) => _controller.textStyle =
          Utils.getTextStyleAsComposite(_controller, style: style),
      'defaultFieldBorderColor': (newValue) =>
          _controller.defaultFieldBorderColor = Utils.getColor(newValue),
      'activeFieldBorderColor': (newValue) =>
          _controller.activeFieldBorderColor = Utils.getColor(newValue),
      'defaultFieldBackgroundColor': (newValue) =>
          _controller.defaultFieldBackgroundColor = Utils.getColor(newValue),
      'activeFieldBackgroundColor': (newValue) =>
          _controller.activeFieldBackgroundColor = Utils.getColor(newValue),
      'filledFieldBackgroundColor': (newValue) =>
          _controller.filledFieldBackgroundColor = Utils.getColor(newValue),
      'filledFieldBorderColor': (newValue) =>
          _controller.filledFieldBorderColor = Utils.getColor(newValue),
      'cursorColor': (newValue) =>
          _controller.cursorColor = Utils.getColor(newValue),
      'onChange': (funcDefinition) => _controller.onChange =
          EnsembleAction.fromYaml(funcDefinition, initiator: this),
      'onComplete': (funcDefinition) => _controller.onComplete =
          EnsembleAction.fromYaml(funcDefinition, initiator: this),
    };
  }

  @override
  Map<String, Function> methods() {
    return {};
  }

  @override
  ConfirmationInputState createState() => ConfirmationInputState();

  TextInputType get keyboardType {
    // set the best keyboard type based on the input type
    if (_controller.inputType == InputType.email.name) {
      return TextInputType.emailAddress;
    } else if (_controller.inputType == InputType.phone.name) {
      return TextInputType.phone;
    } else if (_controller.inputType == InputType.number.name) {
      return TextInputType.number;
    } else if (_controller.inputType == InputType.text.name) {
      return TextInputType.text;
    } else if (_controller.inputType == InputType.url.name) {
      return TextInputType.url;
    } else if (_controller.inputType == InputType.datetime.name) {
      return TextInputType.datetime;
    }
    return TextInputType.number;
  }
}

class ConfirmationInputController extends BoxController {
  String? text;
  late int length;
  bool? autoComplete;
  bool? enableCursor;
  String? fieldType;
  String? inputType;
  Color? defaultFieldBorderColor;
  Color? activeFieldBorderColor;
  Color? defaultFieldBackgroundColor;
  Color? activeFieldBackgroundColor;
  Color? filledFieldBackgroundColor;
  Color? filledFieldBorderColor;
  Color? cursorColor;
  EnsembleAction? onChange;
  EnsembleAction? onComplete;

  TextStyleComposite? _textStyle;
  TextStyleComposite get textStyle => _textStyle ??= TextStyleComposite(this);
  set textStyle(TextStyleComposite style) => _textStyle = style;
}

class ConfirmationInputState extends framework.WidgetState<ConfirmationInput> {
  @override
  Widget buildWidget(BuildContext context) {
    return BoxWrapper(
      widget: buildTextInput(widget.controller),
      boxController: widget.controller,
    );
  }

  Widget buildTextInput(ConfirmationInputController controller) {
    return OtpPinField(
      otpPinFieldStyle: OtpPinFieldStyle(
        textStyle: controller.textStyle.getTextStyle(),
        defaultFieldBorderColor:
            controller.defaultFieldBorderColor ?? Colors.black45,
        activeFieldBorderColor:
            controller.activeFieldBorderColor ?? Colors.black,
        defaultFieldBackgroundColor:
            controller.defaultFieldBackgroundColor ?? Colors.transparent,
        activeFieldBackgroundColor:
            controller.activeFieldBackgroundColor ?? Colors.transparent,
        filledFieldBackgroundColor:
            controller.filledFieldBackgroundColor ?? Colors.transparent,
        filledFieldBorderColor:
            controller.filledFieldBorderColor ?? Colors.transparent,
      ),
      maxLength: controller.length,
      keyboardType: widget.keyboardType,
      otpPinFieldDecoration: controller.fieldType?.otpPinField ??
          OtpPinFieldDecoration.defaultPinBoxDecoration,
      cursorColor: controller.cursorColor,
      autoComplete: controller.autoComplete ?? true,
      onChange: _onChange,
      onSubmit: _onComplete,
    );
  }

  void _onChange(String text) {
    widget._controller.text = text;
    if (widget._controller.onChange != null) {
      ScreenController().executeAction(context, widget._controller.onChange!);
    }
  }

  void _onComplete(String text) {
    widget._controller.text = text;
    if (widget._controller.onComplete != null) {
      ScreenController().executeAction(context, widget._controller.onComplete!);
    }
  }
}

extension FieldTypeOtpValue on String {
  OtpPinFieldDecoration get otpPinField {
    switch (this) {
      case 'default':
        return OtpPinFieldDecoration.defaultPinBoxDecoration;
      case 'rounded':
        return OtpPinFieldDecoration.roundedPinBoxDecoration;
      case 'underline':
        return OtpPinFieldDecoration.underlinedPinBoxDecoration;
      default:
        return OtpPinFieldDecoration.defaultPinBoxDecoration;
    }
  }
}