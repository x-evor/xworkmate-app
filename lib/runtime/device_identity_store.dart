import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';

import 'runtime_models.dart';
import 'secure_config_store.dart';

class DeviceIdentityStore {
  DeviceIdentityStore(this._store);

  final SecureConfigStore _store;
  final Ed25519 _algorithm = Ed25519();

  Future<LocalDeviceIdentity> loadOrCreate() async {
    final existing = await _store.loadDeviceIdentity();
    if (existing != null &&
        existing.deviceId.isNotEmpty &&
        existing.publicKeyBase64Url.isNotEmpty &&
        existing.privateKeyBase64Url.isNotEmpty) {
      return existing;
    }

    final keyPair = await _algorithm.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final publicKeyBytes = publicKey.bytes;
    final identity = LocalDeviceIdentity(
      deviceId: _deriveDeviceId(publicKeyBytes),
      publicKeyBase64Url: _base64UrlEncode(publicKeyBytes),
      privateKeyBase64Url: _base64UrlEncode(privateKeyBytes),
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _store.saveDeviceIdentity(identity);
    return identity;
  }

  Future<String> signPayload({
    required LocalDeviceIdentity identity,
    required String payload,
  }) async {
    final publicKeyBytes = _base64UrlDecode(identity.publicKeyBase64Url);
    final privateKeyBytes = _base64UrlDecode(identity.privateKeyBase64Url);
    final keyPair = SimpleKeyPairData(
      privateKeyBytes,
      publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519),
      type: KeyPairType.ed25519,
    );
    final signature = await _algorithm.sign(
      utf8.encode(payload),
      keyPair: keyPair,
    );
    return _base64UrlEncode(signature.bytes);
  }

  String normalizeMetadataForAuth(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '';
    }
    final buffer = StringBuffer();
    for (final rune in trimmed.runes) {
      if (rune >= 65 && rune <= 90) {
        buffer.writeCharCode(rune + 32);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  String buildDeviceAuthPayloadV3({
    required String deviceId,
    required String clientId,
    required String clientMode,
    required String role,
    required List<String> scopes,
    required int signedAtMs,
    required String token,
    required String nonce,
    required String platform,
    required String deviceFamily,
  }) {
    return [
      'v3',
      deviceId,
      clientId,
      clientMode,
      role,
      scopes.join(','),
      '$signedAtMs',
      token,
      nonce,
      normalizeMetadataForAuth(platform),
      normalizeMetadataForAuth(deviceFamily),
    ].join('|');
  }

  String _deriveDeviceId(List<int> publicKeyBytes) {
    return crypto.sha256.convert(publicKeyBytes).toString();
  }

  static String _base64UrlEncode(List<int> value) {
    return base64Url.encode(value).replaceAll('=', '');
  }

  static Uint8List _base64UrlDecode(String value) {
    final normalized = value.replaceAll('-', '+').replaceAll('_', '/');
    final padded = normalized + '=' * ((4 - normalized.length % 4) % 4);
    return Uint8List.fromList(base64.decode(padded));
  }
}
