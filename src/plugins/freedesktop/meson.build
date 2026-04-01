freedesktop_plugin_resources = gnome.compile_resources(
  'freedesktop-plugin-resources',
  'freedesktop.gresource.xml',
  c_name: 'freedesktop_plugin',
)

libft_plugin_freedesktop = static_library(
  'ft_plugin_freedesktop',
  files(
    'interfaces.vala',
    'freedesktop.vala',
    'lock-screen-provider.vala',
    'notification-backend-provider.vala',
    'screen-saver-provider.vala',
    'sleep-monitor-provider.vala',
    'timezone-monitor-provider.vala',
  ) + freedesktop_plugin_resources,
  dependencies: [libft_core_dep, gio_dep, peas_dep],
  include_directories: config_h_dir,
)
