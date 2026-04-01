/*
 * Copyright (c) 2026 focus-timer contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Gnome
{
    [ModuleInit]
    public void peas_register_types (GLib.TypeModule module)
    {
        var object_module = module as Peas.ObjectModule;

        object_module.register_extension_type (typeof (Ft.DesktopExtensionProvider),
                                               typeof (Gnome.DesktopExtensionProvider));

        object_module.register_extension_type (typeof (Ft.ScreenOverlayProvider),
                                               typeof (Gnome.ScreenOverlayProvider));

        object_module.register_extension_type (typeof (Ft.ScreenSaverProvider),
                                               typeof (Gnome.ScreenSaverProvider));

        object_module.register_extension_type (typeof (Ft.IdleMonitorProvider),
                                               typeof (Gnome.IdleMonitorProvider));

        object_module.register_extension_type (typeof (Ft.PreferencesWindowExtension),
                                               typeof (Gnome.PreferencesWindowExtension));
    }
}
