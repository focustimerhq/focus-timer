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
    'application-extension.vala',
    'desktop-extension-settings.vala',
    'idle-monitor-provider.vala',
    'install-extension-dialog.vala',
    'preferences.vala',
    'screen-overlay-provider.vala',
    'screen-saver-provider.vala',
    'shell-extension.vala',
    'window-extension.vala',
  ) + gnome_plugin_resources,
  dependencies: [libft_ui_dep],
  include_directories: config_h_dir,
)
