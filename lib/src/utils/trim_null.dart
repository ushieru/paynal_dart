import 'package:paynal/src/models/bytes.dart';

String trimNull(String payload) =>
    payload.replaceAll(nullByte, '').replaceAll(breakByte, '');
