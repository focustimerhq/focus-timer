portal_plugin_resources = gnome.compile_resources(
  'portal-plugin-resources',
  'portal.gresource.xml',
  c_name: 'portal_plugin',
)

libft_plugin_portal = static_library(
  'ft_plugin_portal',
  files(
    'interfaces.vala',
    'portal.vala',
    'request.vala',
    'background-provider.vala',
    'global-shortcuts-provider.vala',
  ) + portal_plugin_resources,
  dependencies: [libft_core_dep, gio_dep, peas_dep],
  include_directories: config_h_dir,
)
