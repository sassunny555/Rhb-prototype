import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

@JS('bankingCaptureFrame')
external JSString? _capture();
@JS('bankingRecognizeText')
external JSPromise<JSString> _recognize(JSString image);
Future<Uint8List?> captureCameraFrame() async {
  final frame = _capture()?.toDart;
  return frame == null ? null : base64Decode(frame.split(',').last);
}

Future<String> recognizeText({Uint8List? bytes}) async {
  if (bytes == null) return '';
  return (await _recognize(
    'data:image/jpeg;base64,${base64Encode(bytes)}'.toJS,
  ).toDart).toDart;
}
