/*
 * Copyright (c) 2026 focus-timer contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 *
 * This module holds public interfaces for Peas extensions.
 */

namespace Ft
{
    public abstract class ApplicationExtension : GLib.Object
    {
    }


    public abstract class WindowExtension : GLib.Object
    {
        public Ft.Window? window {
            owned get {
                return this.window_ref.@get () as Ft.Window;
            }
            set {
                this.window_ref.@set (value);
            }
        }

        private GLib.WeakRef window_ref;
    }


    public abstract class PreferencesWindowExtension : GLib.Object
    {
        public Ft.PreferencesWindow? window {
            owned get {
                return this.window_ref.@get () as Ft.PreferencesWindow;
            }
            set {
                this.window_ref.@set (value);
            }
        }

        private GLib.WeakRef window_ref;
    }
}
