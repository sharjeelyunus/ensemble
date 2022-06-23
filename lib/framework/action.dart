


import 'package:ensemble_ts_interpreter/invokables/invokable.dart';
import 'package:yaml/yaml.dart';

/// payload representing an Action to do (navigateToScreen, InvokeAPI, ..)
abstract class EnsembleAction {
  EnsembleAction({this.initiator});

  // initiator is an Invokable so we can scope to *this* variable
  Invokable? initiator;
}

class InvokeAPIAction extends EnsembleAction {
  InvokeAPIAction({
    Invokable? initiator,
    required this.apiName,
    this.inputs,
    this.onResponse,
    this.onError
  }) : super(initiator: initiator);

  final String apiName;
  final Map<String, dynamic>? inputs;
  EnsembleAction? onResponse;
  EnsembleAction? onError;
}

class NavigateScreenAction extends BaseNavigateScreenAction {
  NavigateScreenAction({
    Invokable? initiator,
    required String screenName,
    Map<String, dynamic>? inputs
  }) : super(initiator: initiator, screenName: screenName, asModal: false, inputs: inputs);
}

class NavigateModalScreenAction extends BaseNavigateScreenAction {
  NavigateModalScreenAction({
    Invokable? initiator,
    required String screenName,
    Map<String, dynamic>? inputs
    }) : super(initiator: initiator, screenName: screenName, asModal: true, inputs: inputs);

}

abstract class BaseNavigateScreenAction extends EnsembleAction {
  BaseNavigateScreenAction({
    Invokable? initiator,
    required this.screenName,
    required this.asModal,
    this.inputs
  }) : super(initiator: initiator);

  String screenName;
  bool asModal;
  Map<String, dynamic>? inputs;
}

class ExecuteCodeAction extends EnsembleAction {
  ExecuteCodeAction({
    Invokable? initiator,
    required this.codeBlock,
  }) : super(initiator: initiator);

  String codeBlock;
}


enum ActionType { invokeAPI, navigateScreen, showModalScreen, executeCode }