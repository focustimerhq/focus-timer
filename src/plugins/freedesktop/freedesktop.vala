/*
 * Copyright (c) 2026 focus-timer contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Freedesktop
{
    [ModuleInit]
    public void peas_register_types (GLib.TypeModule module)
    {
        var object_module = module as Peas.ObjectModule;

        object_module.register_extension_type (typeof (Ft.NotificationBackendProvider),
                                               typeof (Freedesktop.NotificationBackendProvider));

        object_module.register_extension_type (typeof (Ft.LockScreenProvider),
                                               typeof (Freedesktop.LockScreenProvider));

        object_module.register_extension_type (typeof (Ft.ScreenSaverProvider),
                                               typeof (Freedesktop.ScreenSaverProvider));

        object_module.register_extension_type (typeof (Ft.SleepMonitorProvider),
                                               typeof (Freedesktop.SleepMonitorProvider));

        object_module.register_extension_type (typeof (Ft.TimeZoneMonitorProvider),
                                               typeof (Freedesktop.TimeZoneMonitorProvider));
    }
}
