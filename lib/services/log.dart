import 'dart:convert';
import 'dart:developer' as dev;

void log(Object? value, {String name = 'LOG'}) {
  if (value == null) {
    dev.log('null', name: name);
    return;
  }

  dynamic data = value;

  // toJson() 있으면 자동 호출
  try {
    final dynamic obj = value;
    if (obj.toJson is Function) {
      data = obj.toJson();
    }
  } catch (_) {}

  // JSON pretty 출력
  if (data is Map || data is List) {
    const encoder = JsonEncoder.withIndent('  ');
    final pretty = encoder.convert(data);
    dev.log(pretty, name: name);
    return;
  }

  // 나머지는 문자열
  dev.log(data.toString(), name: name);
}
