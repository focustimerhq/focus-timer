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
        public GLib.Object? window {
            get {
                return this._window;
            }
            set {
                this._window = value;
            }
        }

        private unowned GLib.Object? _window = null;

        public virtual void window_mapped ()
        {
        }
    }


    public abstract class PreferencesWindowExtension : GLib.Object
    {
        public GLib.Object? current_navigation_page {
            get {
                return this._current_navigation_page;
            }
            set {
                this._current_navigation_page = value;
            }
        }
        public GLib.Object? current_page {
            get {
                return this._current_page;
            }
            set {
                this._current_page = value;
            }
        }

        private unowned GLib.Object? _current_navigation_page = null;
        private unowned GLib.Object? _current_page = null;

        public virtual void handle_panel_changed ()
        {
        }
    }
}
