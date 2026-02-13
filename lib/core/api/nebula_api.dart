import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:nebula_core/nebula_core_bindings_generated.dart';

/// High-level Dart wrapper for Nebula Core FFI
///
/// Implements "Caller Allocates, Caller Frees" memory safety pattern.
/// All native memory allocations are managed by this class and properly freed.
class NebulaApi {
  late final NebulaCoreBindings _bindings;
  late final ffi.DynamicLibrary _dylib;

  NebulaApi() {
    _dylib = _loadLibrary();
    _bindings = NebulaCoreBindings(_dylib);
  }

  /// Load the native library based on platform
  ffi.DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return ffi.DynamicLibrary.open('libnebula_core.so');
    } else if (Platform.isLinux) {
      // Try multiple paths for Linux (Flutter may put in lib or lib64)
      try {
        return ffi.DynamicLibrary.open('libnebula_core.so');
      } catch (e) {
        // Fallback: try executable's directory structure
        final exePath = Platform.resolvedExecutable;
        final exeDir = exePath.substring(0, exePath.lastIndexOf('/'));
        try {
          return ffi.DynamicLibrary.open('$exeDir/lib/libnebula_core.so');
        } catch (_) {
          return ffi.DynamicLibrary.open('$exeDir/lib64/libnebula_core.so');
        }
      }
    } else if (Platform.isWindows) {
      return ffi.DynamicLibrary.open('nebula_core.dll');
    } else if (Platform.isMacOS) {
      return ffi.DynamicLibrary.open('libnebula_core.dylib');
    } else if (Platform.isIOS) {
      return ffi.DynamicLibrary.process();
    }
    throw UnsupportedError(
        'Platform ${Platform.operatingSystem} not supported');
  }

  /// Initialize Nebula Core
  ///
  /// Returns 0 on success, error code otherwise.
  int init() {
    return _bindings.nebula_init();
  }

  /// Cleanup Nebula Core resources
  void cleanup() {
    _bindings.nebula_cleanup();
  }

  /// Get Nebula Core version string
  ///
  /// Returns version in format "major.minor.patch"
  String version() {
    final versionPtr = _bindings.nebula_version();
    if (versionPtr == ffi.nullptr) {
      return 'unknown';
    }
    // C string is static, no need to free
    return versionPtr.cast<Utf8>().toDartString();
  }

  /// Send Telegram authentication code
  ///
  /// [phone] Phone number in international format (e.g., "+1234567890")
  /// Returns 0 on success, error code otherwise.
  int sendTelegramCode(String phone) {
    // Caller allocates
    final phonePtr = phone.toNativeUtf8();
    try {
      return _bindings.telegram_send_code(phonePtr.cast<ffi.Char>());
    } finally {
      // Caller frees
      calloc.free(phonePtr);
    }
  }

  /// Verify Telegram authentication code
  ///
  /// [code] Authentication code received via SMS/Telegram
  /// Returns 0 on success, error code otherwise.
  int checkTelegramCode(String code) {
    // Caller allocates
    final codePtr = code.toNativeUtf8();
    try {
      return _bindings.telegram_check_code(codePtr.cast<ffi.Char>());
    } finally {
      // Caller frees
      calloc.free(codePtr);
    }
  }

  /// Encrypt data chunk with AES-256-GCM
  ///
  /// [input] Plaintext data bytes
  /// [key] Base64-encoded encryption key
  /// [iv] Initialization vector (12 bytes for GCM)
  ///
  /// Returns encrypted data with authentication tag, or null on error.
  List<int>? encryptChunk(List<int> input, String key, List<int> iv) {
    if (iv.length != 12) {
      throw ArgumentError('IV must be exactly 12 bytes for AES-GCM');
    }

    // Caller allocates input buffer
    final inputPtr = calloc<ffi.Uint8>(input.length);
    // Caller allocates output buffer (input size + 16 bytes for auth tag)
    final outputPtr = calloc<ffi.Uint8>(input.length + 16);
    // Caller allocates IV buffer
    final ivPtr = calloc<ffi.Uint8>(iv.length);
    // Caller allocates key string
    final keyPtr = key.toNativeUtf8();

    try {
      // Copy input data
      for (int i = 0; i < input.length; i++) {
        inputPtr[i] = input[i];
      }
      // Copy IV
      for (int i = 0; i < iv.length; i++) {
        ivPtr[i] = iv[i];
      }

      final resultLen = _bindings.aes_encrypt_chunk(
        inputPtr,
        input.length,
        outputPtr,
        keyPtr.cast<ffi.Char>(),
        ivPtr,
      );

      if (resultLen < 0) {
        return null; // Error occurred
      }

      // Copy result to Dart list
      return List<int>.generate(resultLen, (i) => outputPtr[i]);
    } finally {
      // Caller frees all allocations
      calloc.free(inputPtr);
      calloc.free(outputPtr);
      calloc.free(ivPtr);
      calloc.free(keyPtr);
    }
  }

  /// Decrypt data chunk with AES-256-GCM
  ///
  /// [input] Encrypted data bytes (includes 16-byte authentication tag)
  /// [key] Base64-encoded encryption key
  /// [iv] Initialization vector (12 bytes for GCM)
  ///
  /// Returns decrypted data, or null on error.
  List<int>? decryptChunk(List<int> input, String key, List<int> iv) {
    if (iv.length != 12) {
      throw ArgumentError('IV must be exactly 12 bytes for AES-GCM');
    }
    if (input.length < 16) {
      throw ArgumentError('Input must include at least 16-byte auth tag');
    }

    // Caller allocates buffers
    final inputPtr = calloc<ffi.Uint8>(input.length);
    final outputPtr = calloc<ffi.Uint8>(input.length);
    final ivPtr = calloc<ffi.Uint8>(iv.length);
    final keyPtr = key.toNativeUtf8();

    try {
      // Copy input data
      for (int i = 0; i < input.length; i++) {
        inputPtr[i] = input[i];
      }
      // Copy IV
      for (int i = 0; i < iv.length; i++) {
        ivPtr[i] = iv[i];
      }

      final resultLen = _bindings.aes_decrypt_chunk(
        inputPtr,
        input.length,
        outputPtr,
        keyPtr.cast<ffi.Char>(),
        ivPtr,
      );

      if (resultLen < 0) {
        return null; // Error occurred
      }

      // Copy result to Dart list
      return List<int>.generate(resultLen, (i) => outputPtr[i]);
    } finally {
      // Caller frees all allocations
      calloc.free(inputPtr);
      calloc.free(outputPtr);
      calloc.free(ivPtr);
      calloc.free(keyPtr);
    }
  }

  /// Derive master key using Argon2id
  ///
  /// [password] User password
  /// [salt] 16-byte salt
  /// [iterations] Argon2 iterations
  /// [memoryKb] Argon2 memory in KB
  /// [parallelism] Argon2 parallelism factor
  /// [outputKey] Pre-allocated 32-byte buffer for the result
  ///
  /// Returns 0 on success, error code otherwise.
  int deriveMasterKey(
    String password,
    ffi.Pointer<ffi.Uint8> salt,
    int saltLen,
    int iterations,
    int memoryKb,
    int parallelism,
    ffi.Pointer<ffi.Uint8> outputKey,
  ) {
    final passwordPtr = password.toNativeUtf8();
    try {
      return _bindings.nebula_derive_master_key(
        passwordPtr.cast<ffi.Char>(),
        salt,
        saltLen,
        iterations,
        memoryKb,
        parallelism,
        outputKey,
      );
    } finally {
      calloc.free(passwordPtr);
    }
  }
}
