part of 'web3_ethereum.dart';

/// Converts request parameters from darts language to vanilla javascript
/// List destruction is used to convert to JavaScript Array
Object _parseDartParamsToJs(List<dynamic> params) {
  return [
    ...params.where(_nullToUndefinedFilter).map((param) {
      return _parseParam(param);
    })
  ];
}

Object _parseParam(Object param) {
  if(param is Map) return _mapToJSObj(param);
  if (param is List) return [...param.where(_nullToUndefinedFilter).map((item) => _parseParam(item))];
  return param;
}

/// Creates a vanilla literal JavaScript object from a Dart Map
/// And removes empty fields
Object _mapToJSObj(Map<dynamic, dynamic> a) {
  var object = newObject();
  a.forEach((k, v) {
    var key = k;
    var value = v;
    if (_nullToUndefinedFilter(value)) {
      setProperty(object, key, _parseParam(value));
    }
  });
  return object;
}

/// Used to remove null values from query arguments
/// because JavaScript expects undefined, not null for undeclared value.
bool _nullToUndefinedFilter(dynamic item) {
  return item != null;
}