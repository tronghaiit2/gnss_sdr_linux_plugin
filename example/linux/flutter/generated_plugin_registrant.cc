//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <new_linux_plugin/new_linux_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) new_linux_plugin_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "NewLinuxPlugin");
  new_linux_plugin_register_with_registrar(new_linux_plugin_registrar);
}
