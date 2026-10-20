#include <dlfcn.h>

#include "my_application.h"

// Flutter's libepoxy opens libGLESv2.so.2 by name and aborts if it is absent.
// A loaded copy satisfies that lookup, so try the system copy, then the bundle.
static gboolean load_gles() {
  if (dlopen("libGLESv2.so.2", RTLD_NOW | RTLD_GLOBAL) != nullptr) {
    return TRUE;
  }

  g_autoptr(GError) error = nullptr;
  g_autofree gchar* exe = g_file_read_link("/proc/self/exe", &error);
  if (exe == nullptr) {
    g_critical("Failed to find the executable: %s", error->message);
    return FALSE;
  }
  g_autofree gchar* dir = g_path_get_dirname(exe);
  g_autofree gchar* bundled =
      g_build_filename(dir, "lib", "gles", "libGLESv2.so.2", nullptr);
  if (dlopen(bundled, RTLD_NOW | RTLD_GLOBAL) == nullptr) {
    g_critical("Failed to load libGLESv2.so.2: %s", dlerror());
    return FALSE;
  }
  return TRUE;
}

int main(int argc, char** argv) {
  if (!load_gles()) {
    return 1;
  }

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
