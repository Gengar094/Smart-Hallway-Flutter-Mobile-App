import 'dart:io';

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

bool isValidIpAddress(String ip) {
  try {
    InternetAddress address = InternetAddress(ip);
    if (address.type == InternetAddressType.IPv4 || address.type == InternetAddressType.IPv6) {
      return true;
    }
  } catch (e) {
    return false;
  }
  return false;
}

bool isValidPortNumber(String port) {
  try {
    int p = int.parse(port);
    return p > 0 && p < 65536;
  } catch (e) {
    return false;
  }
}
