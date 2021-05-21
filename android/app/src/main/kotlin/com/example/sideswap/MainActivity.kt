package com.example.sideswap

import android.os.Bundle
import android.security.keystore.KeyProperties
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import java.util.concurrent.Executor
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.IvParameterSpec

class MainActivity : FlutterFragmentActivity() {

    private val ANDROID_KEY_STORE = "AndroidKeyStore";

    private val CHANNEL = "app.sideswap.io/encryption"

    private val KEY_NAME = "MAIN_KEY"

    private val ERROR_OTHER = "other";
    private val ERROR_NEGATIVE = "negative";

    private lateinit var executor: Executor

    val SPEC_KEY_TYPE = KeyProperties.KEY_ALGORITHM_AES
    val SPEC_BLOCK_MODE = KeyProperties.BLOCK_MODE_CBC
    val SPEC_PADDING = KeyProperties.ENCRYPTION_PADDING_PKCS7

    val SPEC_CIPHER = "$SPEC_KEY_TYPE/$SPEC_BLOCK_MODE/$SPEC_PADDING"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        executor = ContextCompat.getMainExecutor(this)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "encrypt") {
                val data = call.arguments as ByteArray;
                process(Cipher.ENCRYPT_MODE, result, data)
            } else if (call.method == "decrypt") {
                val data = call.arguments as ByteArray;
                process(Cipher.DECRYPT_MODE, result, data)
            } else{
                result.notImplemented()
            }
        }
    }

    private fun getSecretKey(): SecretKey {
        val keyStore = KeyStore.getInstance(ANDROID_KEY_STORE)

        // Before the keystore can be accessed, it must be loaded.
        keyStore.load(null)

        var key = keyStore.getKey(KEY_NAME, null)

        if (key == null) {
            val keyGenParameterSpec = android.security.keystore.KeyGenParameterSpec.Builder(
                    KEY_NAME,
                    KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                    .setBlockModes(SPEC_BLOCK_MODE)
                    .setEncryptionPaddings(SPEC_PADDING)
                    .setUserAuthenticationRequired(true)
                    // Invalidate the keys if the user has registered a new biometric
                    // credential, such as a new fingerprint. Can call this method only
                    // on Android 7.0 (API level 24) or higher. The variable
                    // "invalidatedByBiometricEnrollment" is true by default.
                    //.setInvalidatedByBiometricEnrollment(true)
                    .build()
            val keyGenerator = KeyGenerator.getInstance(
                    KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEY_STORE)
            keyGenerator.init(keyGenParameterSpec)
            key = keyGenerator.generateKey()
        }

        return key as SecretKey
    }

    private fun getCipher(): Cipher {
        return Cipher.getInstance(SPEC_CIPHER)
    }

    private fun process(opmode: Int, chan: MethodChannel.Result, inData: ByteArray) {
        val key = getSecretKey();

        val cipher = getCipher()

        var inDataWithoutIv = inData;
        if (opmode == Cipher.ENCRYPT_MODE) {
            cipher.init(opmode, key)
        } else {
            val iv = inData.take(cipher.blockSize).toByteArray()
            cipher.init(opmode, key, IvParameterSpec(iv))
            inDataWithoutIv = inData.drop(cipher.blockSize).toByteArray()
        }

        val biometricPrompt = BiometricPrompt(this, executor,
                object : BiometricPrompt.AuthenticationCallback() {
                    override fun onAuthenticationError(errorCode: Int,
                                                       errString: CharSequence) {
                        super.onAuthenticationError(errorCode, errString)
                        if (errorCode == BiometricPrompt.ERROR_NEGATIVE_BUTTON) {
                            chan.error(ERROR_NEGATIVE, errString.toString(), null);
                        } else {
                            chan.error(ERROR_OTHER, errString.toString(), null);
                        }
                    }

                    override fun onAuthenticationSucceeded(
                            result: BiometricPrompt.AuthenticationResult) {
                        super.onAuthenticationSucceeded(result)
                        val outData = result.cryptoObject!!.cipher!!.doFinal(
                                inDataWithoutIv)
                        if (opmode == Cipher.ENCRYPT_MODE) {
                            chan.success(cipher.iv.plus(outData))
                        } else {
                            chan.success(outData)
                        }
                    }

                    override fun onAuthenticationFailed() {
                        // Called when wrong fingerprint detect
                        super.onAuthenticationFailed()
                    }
                });

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
                .setTitle("Biometric login")
                .setSubtitle("Log in using your biometric credential")
                .setNegativeButtonText("Cancel")
                .setConfirmationRequired(true)
                .build()

        biometricPrompt.authenticate(promptInfo, BiometricPrompt.CryptoObject(cipher))
    }
}
