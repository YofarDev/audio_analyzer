package fr.yofardev.audio_analyzer

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import linc.com.amplituda.Amplituda
import linc.com.amplituda.Cache
import linc.com.amplituda.AmplitudaResult
import linc.com.amplituda.exceptions.AmplitudaException

class AudioAnalyzerPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var amplituda: Amplituda

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_analyzer")
        channel.setMethodCallHandler(this)
        amplituda = Amplituda(flutterPluginBinding.applicationContext)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getAmplitudes" -> {
                val filePath = call.argument<String>("filePath")
                val samplesPerSecond = call.argument<Int>("samplesPerSecond") ?: 40
                if (filePath != null) {
                    getAmplitudes(filePath, samplesPerSecond, result)
                } else {
                    result.error("INVALID_ARGUMENT", "File path is required", null)
                }
            }
            "clearCache" -> {
                amplituda.clearCache()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
        }
    

private fun getAmplitudes(filePath: String, samplesPerSecond: Int, result: Result) {
    try {
        val processingOutput = amplituda.processAudio(filePath, Cache.withParams(Cache.REUSE))
        val amplitudaResult = processingOutput.get()
        val amplitudes = amplitudaResult.amplitudesAsList()
        result.success(amplitudes)
    } catch (e: AmplitudaException) {
        result.error("AMPLITUDE_ERROR", e.message, null)
    } catch (e: Exception) {
        result.error("UNKNOWN_ERROR", "An unknown error occurred", null)
    }
}

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}