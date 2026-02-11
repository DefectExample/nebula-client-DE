import 'dart:ffi' as ffi;
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:nebula_client/core/api/nebula_api.dart';

class KdfRequest {
  final String password;
  final Uint8List salt;

  KdfRequest(this.password, this.salt);
}

class AuthRepository {
  /// Derives a 32-byte master key from password and salt using Argon2id.
  Future<Uint8List> deriveSessionKey(String password, Uint8List salt) async {
    return await compute(_kdfTask, KdfRequest(password, salt));
  }

  /// KDF execution task running in a background isolate.
  static Uint8List _kdfTask(KdfRequest request) {
    final api = NebulaApi();
    final saltPtr = calloc<ffi.Uint8>(request.salt.length);
    final keyPtr = calloc<ffi.Uint8>(32);

    try {
      for (int i = 0; i < request.salt.length; i++) {
        saltPtr[i] = request.salt[i];
      }

      // Argon2id parameters: t=2, m=64MB, p=1
      final result = api.deriveMasterKey(
        request.password,
        saltPtr,
        request.salt.length,
        2,
        65536,
        1,
        keyPtr,
      );

      if (result != 0) {
        throw Exception('KDF derivation failed (code: $result)');
      }

      final resultKey = Uint8List(32);
      for (int i = 0; i < 32; i++) {
        resultKey[i] = keyPtr[i];
      }

      return resultKey;
    } finally {
      // Zero-fill sensitive native buffers
      for (int i = 0; i < request.salt.length; i++) saltPtr[i] = 0;
      for (int i = 0; i < 32; i++) keyPtr[i] = 0;

      calloc.free(saltPtr);
      calloc.free(keyPtr);
    }
  }
}
