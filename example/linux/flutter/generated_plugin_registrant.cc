//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audio_analyzer/audio_analyzer_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) audio_analyzer_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AudioAnalyzerPlugin");
  audio_analyzer_plugin_register_with_registrar(audio_analyzer_registrar);
}
