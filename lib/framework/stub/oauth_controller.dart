import 'package:ensemble/framework/action.dart';
import 'package:ensemble/framework/error_handling.dart';
import 'package:ensemble/framework/stub/token_manager.dart';
import 'package:flutter/cupertino.dart';

abstract class OAuthController {
  Future<OAuthServiceToken?> authorize(
      BuildContext context, OAuthService service,
      {required String scope,
      bool forceNewTokens = false,
      InvokeAPIAction? tokenExchangeAPI});
}

class OAuthControllerStub implements OAuthController {
  @override
  Future<OAuthServiceToken?> authorize(
      BuildContext context, OAuthService service,
      {required String scope,
      bool forceNewTokens = false,
      InvokeAPIAction? tokenExchangeAPI}) {
    throw ConfigError("Auth module is not enabled.");
  }
}

// pre-defined list of OAuth services we support natively
enum OAuthService { google, microsoft, yahoo }
