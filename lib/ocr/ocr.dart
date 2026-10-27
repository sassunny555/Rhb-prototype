export 'ocr_stub.dart'
    if (dart.library.io) 'ocr_native.dart'
    if (dart.library.js_interop) 'ocr_web.dart';
