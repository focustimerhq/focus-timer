/*
 * Copyright (c) 2026 focus-timer contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Authors: Kamil Prusko <kamilprusko@gmail.com>
 */

namespace Ft
{
    public interface NotificationBackendProvider : Ft.Provider
    {
        public abstract string name { get; }
        public abstract string vendor { get; }
        public abstract string version { get; }
        public abstract bool has_actions { get; }

        public abstract void withdraw_notification (string id);

        public abstract void send_notification (string            id,
                                                GLib.Notification notification);
    }


    internal class DefaultNotificationBackendProvider : Ft.Provider, Ft.NotificationBackendProvider
    {
        public string name {
            get {
                return "";
            }
        }

        public string vendor {
            get {
                return "";
            }
        }

        public string version {
            get {
                return "";
            }
        }

        public bool has_actions {
            get {
                return true;
            }
        }

        private GLib.Application? application = null;

        public void withdraw_notification (string id)
        {
            this.application?.withdraw_notification (id);
        }

        public void send_notification (string            id,
                                       GLib.Notification notification)
        {
            this.application?.send_notification (id, notification);
        }

        public override async void initialize (GLib.Cancellable? cancellable) throws GLib.Error
        {
        }

        public override async void uninitialize () throws GLib.Error
        {
        }

        public override async void enable (GLib.Cancellable? cancellable) throws GLib.Error
        {
            this.application = GLib.Application.get_default ();
        }

        public override async void disable () throws GLib.Error
        {
            this.application = null;
        }
    }


    public interface NotificationBackend : GLib.Object
    {
        public abstract string name { get; }
        public abstract string vendor { get; }
        public abstract string version { get; }
        public abstract bool has_actions { get; }

        public abstract void withdraw_notification (string id);

        public abstract void send_notification (string            id,
                                                GLib.Notification notification);
    }


    /**
     * It's an over-engineered wrapper around `Application.send_notification()`.
     *
     * We need to have info about the backend used. That's why it uses providers.
     *
     * For testing we want whole `DefaultNotificationBackend` to be swapped with a mock.
     */
    internal class DefaultNotificationBackend : Ft.ProvidedObject<Ft.NotificationBackendProvider>, Ft.NotificationBackend
    {
        public string name {
            get {
                return this._name;
            }
        }

        public string vendor {
            get {
                return this._vendor;
            }
        }

        public string version {
            get {
                return this._version;
            }
        }

        public bool has_actions {
            get {
                return this._has_actions;
            }
        }

        private string                                     _name;
        private string                                     _vendor;
        private string                                     _version;
        private bool                                       _has_actions;
        private GLib.HashTable<string, GLib.Notification?> notifications;

        construct
        {
            this._name = "";
            this._vendor = "";
            this._version = "";
            this._has_actions = true;

            // Store notifications in case provider is initialized after a delay
            this.notifications = new GLib.HashTable<string, GLib.Notification?> (GLib.str_hash, GLib.str_equal);
        }

        protected override void initialize ()
        {
        }

        protected override void setup_providers ()
        {
            this.providers.add (new Ft.DefaultNotificationBackendProvider (), Ft.Priority.DEFAULT);
        }

        protected override void provider_enabled (Ft.NotificationBackendProvider provider)
        {
            this._name = provider.name;
            this._vendor = provider.vendor;
            this._version = provider.version;
            this._has_actions = provider.has_actions;

            GLib.debug ("Notification backend:\n  class: %s\n  name: %s\n  vendor: %s\n  version: %s\n  has-actions: %s",
                        provider.get_type ().name (),
                        provider.name,
                        provider.vendor,
                        provider.version,
                        provider.has_actions.to_string ());

            this.notifications.for_each (
                (id, notification) => {
                    if (notification != null) {
                        provider.send_notification (id, notification);
                    }
                    else {
                        provider.withdraw_notification (id);
                    }
                });

            this.notifications.remove_all ();
        }

        protected override void provider_disabled (Ft.NotificationBackendProvider provider)
        {
        }

        public void withdraw_notification (string id)
        {
            unowned var provider = this.provider;

            if (provider != null) {
                provider.withdraw_notification (id);
            }
            else {
                this.notifications.insert (id, null);
            }
        }

        public void send_notification (string            id,
                                       GLib.Notification notification)
        {
            unowned var provider = this.provider;

            if (provider != null) {
                provider.send_notification (id, notification);
            }
            else {
                this.notifications.insert (id, notification);
            }
        }

        public override void dispose ()
        {
            if (this.notifications != null) {
                this.notifications.remove_all ();
                this.notifications = null;
            }

            base.dispose ();
        }
    }
}
