/*
 * Copyright (c) 2026 focus-timer contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Authors: Kamil Prusko <kamilprusko@gmail.com>
 */

using GLib;


namespace Gnome
{
    /**
     * Shell extension manages the overlay itself.
     *
     * We only need support manually opening the overlay here.
     */
    public class ScreenOverlayProvider : Ft.Provider, Ft.ScreenOverlayProvider
    {
        private Ft.DesktopExtension?            extension = null;
        private Gnome.DesktopExtensionProvider? extension_provider = null;

        private void update_available ()
        {
            this.available = this.extension_provider != null &&
                             this.extension_provider.extension_enabled;
        }

        private void update_extension_provider ()
        {
            var extension_provider = this.extension?.provider as Gnome.DesktopExtensionProvider;

            if (this.extension_provider == extension_provider) {
                return;
            }

            if (this.extension_provider != null) {
                this.extension_provider.notify["extension-enabled"].disconnect (this.on_notify_extension_enabled);
            }

            this.extension_provider = extension_provider;

            if (this.extension_provider != null) {
                this.extension_provider.notify["extension-enabled"].connect (this.on_notify_extension_enabled);
            }

            this.update_available ();
        }

        public void open ()
        {
            var proxy = this.extension_provider?.get_shell_integration_proxy ();

            if (proxy != null) {
                proxy.open_screen_overlay.begin (
                    (obj, res) => {
                        try {
                            proxy.open_screen_overlay.end (res);
                        }
                        catch (GLib.Error error) {
                            GLib.warning ("Error opening screen overlay: %s", error.message);
                        }
                    });
            }
            else {
                GLib.debug ("Unable to open screen overlay. No ShellIntegration.");
            }
        }

        public void close ()
        {
        }

        protected override async void initialize (GLib.Cancellable? cancellable) throws GLib.Error
        {
            this.extension = new Ft.DesktopExtension ();
            this.extension.notify["provider"].connect (this.on_notify_provider);

            this.update_extension_provider ();
        }

        protected override async void uninitialize () throws GLib.Error
        {
            if (this.extension != null) {
                this.extension.notify["provider"].disconnect (this.on_notify_provider);
                this.extension = null;

                this.update_extension_provider ();
            }
        }

        protected override async void enable (GLib.Cancellable? cancellable) throws GLib.Error
        {
        }

        protected override async void disable () throws GLib.Error
        {
            this.close ();
        }

        private void on_notify_provider (GLib.Object    object,
                                         GLib.ParamSpec pspec)
        {
            this.update_extension_provider ();
        }

        private void on_notify_extension_enabled (GLib.Object    object,
                                                  GLib.ParamSpec pspec)
        {
            this.update_available ();
        }
    }
}
