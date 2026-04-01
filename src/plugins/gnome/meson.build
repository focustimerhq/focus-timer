gnome_plugin_resources = gnome.compile_resources(
  'gnome-plugin-resources',
  'gnome.gresource.xml',
  c_name: 'gnome_plugin',
)

libft_plugin_gnome = static_library(
  'ft_plugin_gnome',
  files(
    'interfaces.vala',
    'gnome.vala',
    'desktop-extension-provider.vala',
    'desktop-extension-settings.vala',
    'idle-monitor-provider.vala',
    'preferences.vala',
    'screen-overlay-provider.vala',
    'screen-saver-provider.vala',
  ) + gnome_plugin_resources,
  dependencies: [libft_core_dep, gio_dep, peas_dep, libadwaita_dep],
  include_directories: config_h_dir,
)
