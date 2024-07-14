import Flutter
import AVFoundation

public class AudioAnalyzerPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "audio_analyzer", binaryMessenger: registrar.messenger())
        let instance = AudioAnalyzerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getAmplitudes":
            if let args = call.arguments as? [String: Any],
            let filePath = args["filePath"] as? String,
            let samplesPerSecond = args["samplesPerSecond"] as? Int {
              getAmplitudes(filePath: filePath, samplesPerSecond: samplesPerSecond, result: result)
          } else {
              result(FlutterError(code: "INVALID_ARGUMENT", message: "File path and samplesPerSecond are required", details: nil))
          }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
private func getAmplitudes(filePath: String, samplesPerSecond: Int, result: @escaping FlutterResult) {
    let audioURL = URL(fileURLWithPath: filePath)
    
    do {
        let audioFile = try AVAudioFile(forReading: audioURL)
        let format = audioFile.processingFormat
        let frameCount = UInt32(audioFile.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            result(FlutterError(code: "PROCESSING_ERROR", message: "Unable to create audio buffer", details: nil))
            return
        }
        try audioFile.read(into: buffer)
        
        guard let floatChannelData = buffer.floatChannelData, buffer.format.channelCount > 0 else {
            result(FlutterError(code: "PROCESSING_ERROR", message: "Unable to get audio data", details: nil))
            return
        }
        
        let channelData = floatChannelData[0]
        let sampleRate = format.sampleRate
        let windowSize = Int(sampleRate / Double(samplesPerSecond))
        var amplitudes: [Float] = []
        let frameLength = Int(buffer.frameLength)
        
        for i in stride(from: 0, to: frameLength, by: windowSize) {
            let end = min(i + windowSize, frameLength)
            let windowData = Array(UnsafeBufferPointer(start: channelData.advanced(by: i), count: end - i))
            let rms = sqrt(windowData.map { $0 * $0 }.reduce(0, +) / Float(windowData.count))
            amplitudes.append(rms)
        }
        result(amplitudes)
    } catch {
        result(FlutterError(code: "PROCESSING_ERROR", message: error.localizedDescription, details: nil))
    }
}
}