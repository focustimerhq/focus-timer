/*
 * Copyright (c) 2025-2026 focus-timer contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Gnome
{
    public class DesktopExtensionProvider : Ft.Provider, Ft.DesktopExtensionProvider
    {
        private const string EXTENSION_UUID = "focus-timer@focustimerhq.github.io";

        public bool extension_enabled {
            get {
                return this._extension_enabled;
            }
        }

        public Gnome.DesktopExtensionSettings? settings {
            get {
                return this._settings;
            }
        }

        private Gnome.ShellExtensions?          shell_extensions_proxy = null;
        private Gnome.ShellIntegration?         shell_integration_proxy = null;
        private Gnome.ExtensionInfo             extension_info;
        private uint                            shell_watcher_id = 0;
        private uint                            shell_integration_watcher_id = 0;
        private Gnome.DesktopExtensionSettings? _settings = null;
        private bool                            _extension_enabled = false;
        private GLib.Cancellable?               cancellable;

        construct
        {
            this.notify["extension-enabled"].connect (
                (object, pspec) => {
                    var notification_manager = new Ft.NotificationManager ();

                    if (this._extension_enabled) {
                        notification_manager.inhibit ();
                    }
                    else {
                        notification_manager.uninhibit ();
                    }
                });
        }

        private void update_extension_enabled ()
        {
            var enabled = this.extension_info.enabled;

            if (this._extension_enabled != enabled) {
                this._extension_enabled = enabled;
                this.notify_property ("extension-enabled");
            }
        }

        internal unowned Gnome.ShellIntegration? get_shell_integration_proxy ()
        {
            return this.shell_integration_proxy;
        }

        private void on_properties_changed (GLib.Variant changed_properties,
                                            string[]     invalidated_properties)
        {
            this.available = this.shell_extensions_proxy != null &&
                             this.shell_extensions_proxy.user_extensions_enabled;
        }

        /**
         * Respect `user_extensions_enabled` property. If extensions aren't enabled in GNOME,
         * do not mark provider as available.
         */
        private void on_shell_name_appeared (GLib.DBusConnection connection,
                                             string              name,
                                             string              name_owner)
        {
            if (shell_extensions_proxy != null) {
                return;
            }

            try {
                this.shell_extensions_proxy = GLib.Bus.get_proxy_sync<Gnome.ShellExtensions> (
                        GLib.BusType.SESSION,
                        "org.gnome.Shell",
                        "/org/gnome/Shell",
                        GLib.DBusProxyFlags.DO_NOT_AUTO_START,
                        this.cancellable);

                var shell_extensions_proxy = (GLib.DBusProxy) this.shell_extensions_proxy;
                shell_extensions_proxy.g_properties_changed.connect (this.on_properties_changed);

                this.available = this.shell_extensions_proxy.user_extensions_enabled;
            }
            catch (GLib.Error error) {
                GLib.warning ("Error while initializing extensions proxy: %s", error.message);
            }
        }

        private void on_shell_name_vanished (GLib.DBusConnection? connection,
                                             string               name)
        {
            if (this.shell_extensions_proxy == null) {
                return;
            }

            var shell_extensions_proxy = (GLib.DBusProxy) this.shell_extensions_proxy;
            shell_extensions_proxy.g_properties_changed.disconnect (this.on_properties_changed);

            this.shell_extensions_proxy = null;
            this.available = false;
        }

        private void on_shell_integration_name_appeared (GLib.DBusConnection connection,
                                                         string              name,
                                                         string              name_owner)
        {
            if (this.shell_integration_proxy != null) {
                return;
            }

            try {
                this.shell_integration_proxy = GLib.Bus.get_proxy_sync<Gnome.ShellIntegration> (
                        GLib.BusType.SESSION,
                        "io.github.focustimerhq.FocusTimer.ShellIntegration",
                        "/io/github/focustimerhq/FocusTimer/ShellIntegration",
                        GLib.DBusProxyFlags.DO_NOT_AUTO_START,
                        this.cancellable);

                this._settings = new Gnome.DesktopExtensionSettings (this.shell_integration_proxy);
                this.notify_property ("settings");
            }
            catch (GLib.Error error) {
                GLib.warning ("Error while initializing Shell integration proxy: %s", error.message);
            }
        }

        private void on_shell_integration_name_vanished (GLib.DBusConnection? connection,
                                                         string               name)
        {
            if (this._settings != null) {
                this._settings = null;
                this.notify_property ("settings");
            }

            this.shell_integration_proxy = null;
        }

        private void on_extension_state_changed (string                               uuid,
                                                 GLib.HashTable<string, GLib.Variant> state)
        {
            if (uuid == EXTENSION_UUID) {
                this.extension_info = Gnome.ExtensionInfo.deserialize (uuid, state);
                this.update_extension_enabled ();
            }
        }

        public override async void initialize (GLib.Cancellable? cancellable) throws GLib.Error
        {
            this.extension_info = Gnome.ExtensionInfo (EXTENSION_UUID);
            this.cancellable = new GLib.Cancellable ();

            this.shell_watcher_id = GLib.Bus.watch_name (
                    GLib.BusType.SESSION,
                    "org.gnome.Shell",
                    GLib.BusNameWatcherFlags.NONE,
                    this.on_shell_name_appeared,
                    this.on_shell_name_vanished);
            this.shell_integration_watcher_id = GLib.Bus.watch_name (
                    GLib.BusType.SESSION,
                    "io.github.focustimerhq.FocusTimer.ShellIntegration",
                    GLib.BusNameWatcherFlags.NONE,
                    this.on_shell_integration_name_appeared,
                    this.on_shell_integration_name_vanished);
        }

        public override async void uninitialize () throws GLib.Error
        {
            if (this.shell_watcher_id != 0) {
                GLib.Bus.unwatch_name (this.shell_watcher_id);
                this.shell_watcher_id = 0;
            }

            if (this.shell_integration_watcher_id != 0) {
                GLib.Bus.unwatch_name (this.shell_integration_watcher_id);
                this.shell_integration_watcher_id = 0;
            }

            if (this.cancellable != null) {
                this.cancellable.cancel ();
                this.cancellable = null;
            }
        }

        public override async void enable (GLib.Cancellable? cancellable) throws GLib.Error
        {
            this.shell_extensions_proxy.extension_state_changed.connect (
                    this.on_extension_state_changed);

            try {
                this.extension_info = Gnome.ExtensionInfo.deserialize (
                        EXTENSION_UUID,
                        yield this.shell_extensions_proxy.get_extension_info (EXTENSION_UUID));
            }
            catch (GLib.Error error) {
                GLib.warning ("Error while enabling extension provider: %s", error.message);
            }

            this.update_extension_enabled ();
        }

        public override async void disable () throws GLib.Error
        {
            this.shell_extensions_proxy.extension_state_changed.disconnect (
                    this.on_extension_state_changed);
            this.extension_info = Gnome.ExtensionInfo (EXTENSION_UUID);

            this.update_extension_enabled ();
        }


        /*
         * DesktopExtensionProvider
         */

        private inline void log_error (string     message,
                                       GLib.Error error)
        {
            GLib.warning ("%s: %s (%i) '%s'",
                          message,
                          error.domain.to_string (),
                          error.code,
                          error.message);
        }

        public async bool enable_extension ()
        {
            assert (this.shell_extensions_proxy != null);

            try {
                return yield this.shell_extensions_proxy.enable_extension (EXTENSION_UUID);
            }
            catch (GLib.Error error) {
                this.log_error ("Error while enabling extension", error);
                return false;
            }
        }

        public async bool disable_extension ()
        {
            assert (this.shell_extensions_proxy != null);

            try {
                return yield this.shell_extensions_proxy.disable_extension (EXTENSION_UUID);
            }
            catch (GLib.Error error) {
                this.log_error ("Error while disabling extension", error);
                return false;
            }
        }

        public async bool install_extension () throws Ft.DesktopExtensionError
        {
            assert (this.shell_extensions_proxy != null);

            try {
                var result = yield this.shell_extensions_proxy.install_remote_extension (EXTENSION_UUID);

                switch (result)
                {
                    case "successful":
                        return true;

                    case "cancelled":
                        return false;

                    default:
                        GLib.warning ("Unhandled InstallRemoteExtension result: `%s`", result);
                        return false;
                }
            }
            catch (GLib.IOError error) {
                if (error.code == GLib.IOError.TIMED_OUT) {
                    throw new Ft.DesktopExtensionError.TIMED_OUT ("Timed out");
                }

                if (error.code == GLib.IOError.DBUS_ERROR &&
                    error.message.contains ("Shell.Extensions.Error.NotAllowed"))
                {
                    throw new Ft.DesktopExtensionError.NOT_ALLOWED ("Not allowed");
                }

                if (error.code == GLib.IOError.DBUS_ERROR &&
                    error.message.contains ("Shell.Extensions.Error.InfoDownloadFailed") ||
                    error.message.contains ("Shell.Extensions.Error.DownloadFailed"))
                {
                    throw new Ft.DesktopExtensionError.DOWNLOAD_FAILED ("Failed to download the extension");
                }

                this.log_error ("Error while installing extension", error);
                throw new Ft.DesktopExtensionError.OTHER (error.message);
            }
            catch (GLib.Error error) {
                this.log_error ("Error while installing extension", error);
                throw new Ft.DesktopExtensionError.OTHER (error.message);
            }
        }

        public async bool uninstall_extension ()
        {
            assert (this.shell_extensions_proxy != null);

            try {
                return yield this.shell_extensions_proxy.uninstall_extension (EXTENSION_UUID);
            }
            catch (GLib.Error error) {
                this.log_error ("Error while uninstalling extension", error);
                return false;
            }
        }

        public bool is_installed ()
        {
            return this.extension_info.state != Gnome.ExtensionState.UNKNOWN &&
                   this.extension_info.state != Gnome.ExtensionState.UNINSTALLED;
        }
    }
}
