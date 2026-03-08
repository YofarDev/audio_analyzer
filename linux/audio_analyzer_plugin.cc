#include "include/audio_analyzer/audio_analyzer_plugin.h"

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <limits>
#include <string>
#include <vector>

struct _AudioAnalyzerPlugin {
  GObject parent_instance;
};

#define AUDIO_ANALYZER_PLUGIN(obj)                                  \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), audio_analyzer_plugin_get_type(), \
                              AudioAnalyzerPlugin))

G_DEFINE_TYPE(AudioAnalyzerPlugin, audio_analyzer_plugin, g_object_get_type())

struct WavData {
  std::vector<float> samples;
  int sample_rate = 0;
};

uint16_t ReadU16(std::istream& stream) {
  uint8_t bytes[2] = {0, 0};
  stream.read(reinterpret_cast<char*>(bytes), 2);
  return static_cast<uint16_t>(bytes[0]) |
         (static_cast<uint16_t>(bytes[1]) << 8);
}

uint32_t ReadU32(std::istream& stream) {
  uint8_t bytes[4] = {0, 0, 0, 0};
  stream.read(reinterpret_cast<char*>(bytes), 4);
  return static_cast<uint32_t>(bytes[0]) |
         (static_cast<uint32_t>(bytes[1]) << 8) |
         (static_cast<uint32_t>(bytes[2]) << 16) |
         (static_cast<uint32_t>(bytes[3]) << 24);
}

float DecodeSample(const uint8_t* data, uint16_t audio_format,
                   uint16_t bits_per_sample) {
  if (audio_format == 3 && bits_per_sample == 32) {
    float value = 0.0f;
    std::memcpy(&value, data, sizeof(float));
    return std::clamp(value, -1.0f, 1.0f);
  }

  if (audio_format == 1 && bits_per_sample == 8) {
    return (static_cast<int>(data[0]) - 128) / 128.0f;
  }

  if (audio_format == 1 && bits_per_sample == 16) {
    int16_t value = static_cast<int16_t>(static_cast<uint16_t>(data[0]) |
                                         (static_cast<uint16_t>(data[1])
                                          << 8));
    return value / 32768.0f;
  }

  if (audio_format == 1 && bits_per_sample == 24) {
    int32_t value = static_cast<int32_t>(data[0]) |
                    (static_cast<int32_t>(data[1]) << 8) |
                    (static_cast<int32_t>(data[2]) << 16);
    if ((value & 0x00800000) != 0) {
      value |= 0xFF000000;
    }
    return value / 8388608.0f;
  }

  if (audio_format == 1 && bits_per_sample == 32) {
    int32_t value = static_cast<int32_t>(
        static_cast<uint32_t>(data[0]) | (static_cast<uint32_t>(data[1]) << 8) |
        (static_cast<uint32_t>(data[2]) << 16) |
        (static_cast<uint32_t>(data[3]) << 24));
    return value / 2147483648.0f;
  }

  return std::numeric_limits<float>::quiet_NaN();
}

bool ReadWavFile(const std::string& path, WavData& wav_data,
                 std::string& error_message) {
  std::ifstream file(path, std::ios::binary);
  if (!file.is_open()) {
    error_message = "Unable to open audio file";
    return false;
  }

  char riff[4] = {};
  file.read(riff, 4);
  if (std::strncmp(riff, "RIFF", 4) != 0) {
    error_message = "Only RIFF/WAV files are supported on Linux";
    return false;
  }

  ReadU32(file);  // Chunk size.

  char wave[4] = {};
  file.read(wave, 4);
  if (std::strncmp(wave, "WAVE", 4) != 0) {
    error_message = "Invalid WAV header";
    return false;
  }

  uint16_t audio_format = 0;
  uint16_t channels = 0;
  uint32_t sample_rate = 0;
  uint16_t bits_per_sample = 0;
  std::vector<uint8_t> raw_pcm;

  while (file.good()) {
    char chunk_id[4] = {};
    file.read(chunk_id, 4);
    if (file.gcount() != 4) {
      break;
    }

    const uint32_t chunk_size = ReadU32(file);

    if (std::strncmp(chunk_id, "fmt ", 4) == 0) {
      audio_format = ReadU16(file);
      channels = ReadU16(file);
      sample_rate = ReadU32(file);
      ReadU32(file);  // Byte rate.
      ReadU16(file);  // Block align.
      bits_per_sample = ReadU16(file);
      if (chunk_size > 16) {
        file.ignore(chunk_size - 16);
      }
    } else if (std::strncmp(chunk_id, "data", 4) == 0) {
      raw_pcm.resize(chunk_size);
      file.read(reinterpret_cast<char*>(raw_pcm.data()), chunk_size);
      if (file.gcount() != static_cast<std::streamsize>(chunk_size)) {
        error_message = "Failed while reading audio samples";
        return false;
      }
    } else {
      file.ignore(chunk_size);
    }

    if ((chunk_size % 2) != 0) {
      file.ignore(1);
    }
  }

  if (channels == 0 || sample_rate == 0 || bits_per_sample == 0 ||
      raw_pcm.empty()) {
    error_message = "Incomplete WAV file";
    return false;
  }

  if (!(audio_format == 1 || (audio_format == 3 && bits_per_sample == 32))) {
    error_message = "Unsupported WAV encoding";
    return false;
  }

  const int bytes_per_sample = bits_per_sample / 8;
  if (bytes_per_sample <= 0) {
    error_message = "Invalid sample size";
    return false;
  }

  const size_t frame_size = static_cast<size_t>(bytes_per_sample) * channels;
  if (frame_size == 0 || (raw_pcm.size() % frame_size) != 0) {
    error_message = "Corrupted sample data";
    return false;
  }

  const size_t frame_count = raw_pcm.size() / frame_size;
  wav_data.samples.reserve(frame_count);
  wav_data.sample_rate = static_cast<int>(sample_rate);

  for (size_t frame = 0; frame < frame_count; ++frame) {
    const uint8_t* frame_ptr = raw_pcm.data() + frame * frame_size;
    float mono_sample = 0.0f;
    for (uint16_t ch = 0; ch < channels; ++ch) {
      const uint8_t* sample_ptr = frame_ptr + static_cast<size_t>(ch) * bytes_per_sample;
      float decoded = DecodeSample(sample_ptr, audio_format, bits_per_sample);
      if (std::isnan(decoded)) {
        error_message = "Unsupported WAV bit depth";
        return false;
      }
      mono_sample += decoded;
    }
    mono_sample /= static_cast<float>(channels);
    wav_data.samples.push_back(std::clamp(mono_sample, -1.0f, 1.0f));
  }

  return true;
}

std::vector<int> ComputeAmplitudes(const std::vector<float>& samples,
                                   int sample_rate,
                                   int samples_per_second) {
  std::vector<int> amplitudes;
  if (samples.empty() || sample_rate <= 0) {
    return amplitudes;
  }

  const int safe_samples_per_second = std::max(1, samples_per_second);
  const int window_size = std::max(1, sample_rate / safe_samples_per_second);

  for (size_t i = 0; i < samples.size(); i += static_cast<size_t>(window_size)) {
    const size_t end = std::min(samples.size(), i + static_cast<size_t>(window_size));
    double squared_sum = 0.0;
    for (size_t j = i; j < end; ++j) {
      const double sample = samples[j];
      squared_sum += sample * sample;
    }
    const double rms = std::sqrt(squared_sum / static_cast<double>(end - i));
    const int scaled = static_cast<int>(std::round(rms * 100.0));
    amplitudes.push_back(std::clamp(scaled, 0, 100));
  }

  return amplitudes;
}

FlMethodResponse* BuildErrorResponse(const gchar* code,
                                     const std::string& message) {
  return FL_METHOD_RESPONSE(
      fl_method_error_response_new(code, message.c_str(), nullptr));
}

FlMethodResponse* HandleGetAmplitudes(FlValue* args) {
  if (args == nullptr || fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return BuildErrorResponse("INVALID_ARGUMENT", "Expected argument map");
  }

  FlValue* file_path_value = fl_value_lookup_string(args, "filePath");
  FlValue* samples_per_second_value =
      fl_value_lookup_string(args, "samplesPerSecond");

  if (file_path_value == nullptr ||
      fl_value_get_type(file_path_value) != FL_VALUE_TYPE_STRING) {
    return BuildErrorResponse("INVALID_ARGUMENT", "filePath is required");
  }

  const gchar* file_path = fl_value_get_string(file_path_value);
  int samples_per_second = 40;

  if (samples_per_second_value != nullptr) {
    if (fl_value_get_type(samples_per_second_value) == FL_VALUE_TYPE_INT) {
      samples_per_second = static_cast<int>(fl_value_get_int(samples_per_second_value));
    } else {
      return BuildErrorResponse("INVALID_ARGUMENT",
                                "samplesPerSecond must be an integer");
    }
  }

  WavData wav_data;
  std::string read_error;
  if (!ReadWavFile(file_path, wav_data, read_error)) {
    return BuildErrorResponse("PROCESSING_ERROR", read_error);
  }

  const std::vector<int> amplitudes =
      ComputeAmplitudes(wav_data.samples, wav_data.sample_rate,
                        samples_per_second);

  FlValue* result = fl_value_new_list();
  for (int amplitude : amplitudes) {
    fl_value_append(result, fl_value_new_int(amplitude));
  }

  return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

void audio_analyzer_plugin_handle_method_call(AudioAnalyzerPlugin* self,
                                              FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlMethodResponse* response = nullptr;

  if (strcmp(method, "getAmplitudes") == 0) {
    response = HandleGetAmplitudes(fl_method_call_get_args(method_call));
  } else if (strcmp(method, "clearCache") == 0) {
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

void audio_analyzer_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(audio_analyzer_plugin_parent_class)->dispose(object);
}

void audio_analyzer_plugin_class_init(AudioAnalyzerPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = audio_analyzer_plugin_dispose;
}

void audio_analyzer_plugin_init(AudioAnalyzerPlugin* self) {}

void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                    gpointer user_data) {
  AudioAnalyzerPlugin* plugin = AUDIO_ANALYZER_PLUGIN(user_data);
  audio_analyzer_plugin_handle_method_call(plugin, method_call);
}

void audio_analyzer_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  AudioAnalyzerPlugin* plugin = AUDIO_ANALYZER_PLUGIN(
      g_object_new(audio_analyzer_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), "audio_analyzer",
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
