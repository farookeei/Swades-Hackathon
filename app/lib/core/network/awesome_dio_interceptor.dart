import 'dart:convert';
import 'package:colorize/colorize.dart';
import 'package:dio/dio.dart';

class AwesomeDioInterceptor extends Interceptor {
  AwesomeDioInterceptor({
    Styles? requestStyle,
    Styles? responseStyle,
    Styles? errorStyle,
    String? baseUrl,
    bool logRequestHeaders = true,
    void Function(String log)? logger,
  })  : _jsonEncoder = const JsonEncoder.withIndent('  '),
        _baseUrl = baseUrl ?? '',
        _requestStyle = requestStyle ?? Styles.YELLOW,
        _responseStyle = responseStyle ?? Styles.GREEN,
        _errorStyle = errorStyle ?? Styles.RED,
        _logRequestHeaders = logRequestHeaders,
        _logger = logger ?? print;

  final String _baseUrl;
  late final JsonEncoder _jsonEncoder;
  late final bool _logRequestHeaders;
  late final void Function(String log) _logger;
  late final Styles _requestStyle;
  late final Styles _responseStyle;
  late final Styles _errorStyle;

  void _log({required String key, required String value, Styles? style}) {
    final coloredMessage = Colorize('$key$value').apply(style ?? Styles.LIGHT_GRAY);
    _logger('$coloredMessage');
  }

  void _logJson({required String key, dynamic value, Styles? style}) {
    if (value == null) return;
    try {
      final encodedJson = _jsonEncoder.convert(value);
      _log(key: key, value: '\n$encodedJson', style: style);
    } catch (e) {
      _log(key: key, value: ' Cannot format JSON', style: style);
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log(key: '[Request] -> ', value: '${options.method} ${options.uri}', style: _requestStyle);
    if (_logRequestHeaders) {
      _log(key: 'Headers: ', value: options.headers.toString(), style: _requestStyle);
    }
    if (options.data != null) {
      _logJson(key: 'Request Body:', value: options.data, style: _requestStyle);
    }
    _log(key: '', value: '');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log(key: '[Response] -> ', value: '${response.statusCode} ${response.realUri}', style: _responseStyle);
    _logJson(key: 'Response Body:', value: response.data, style: _responseStyle);
    _log(key: '', value: '');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(key: '[Error] -> ', value: '${err.type}: ${err.message}', style: _errorStyle);
    if (err.response != null) {
      _log(key: 'Uri: ', value: '${err.response?.realUri}', style: _errorStyle);
      _log(key: 'Status Code: ', value: '${err.response?.statusCode}', style: _errorStyle);
      _logJson(key: 'Response Body:', value: err.response?.data, style: _errorStyle);
    }
    _log(key: '', value: '');
    handler.next(err);
  }
}
