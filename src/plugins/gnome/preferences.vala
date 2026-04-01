/*
 * Copyright (c) 2026 focus-timer contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Gnome
{
    public class PreferencesWindowExtension : Ft.PreferencesWindowExtension
    {
        public Gnome.DesktopExtensionProvider? provider {
            get {
                return this._provider;
            }
        }

        public Gnome.DesktopExtensionSettings? settings {
            get {
                return this._settings;
            }
        }

        private Ft.DesktopExtension?            desktop_extension = null;
        private Gnome.DesktopExtensionProvider? _provider = null;
        private Gnome.DesktopExtensionSettings? _settings = null;
        private Adw.PreferencesGroup?           indicator_group = null;
        private Adw.PreferencesGroup?           screen_overlay_group = null;

        construct
        {
            this.desktop_extension = new Ft.DesktopExtension ();
            this.desktop_extension.notify["provider"].connect (this.on_notify_provider);

            this.update_provider ();
        }

        private void update_settings ()
        {
            var settings = this._provider?.settings;

            if (this._settings == settings) {
                return;
            }

            this.cleanup ();

            if (this._settings != settings) {
                this._settings = settings;
                this.notify_property ("settings");
            }

            this.handle_panel_changed ();
        }

        private void update_provider ()
        {
            var provider = this.desktop_extension.provider as Gnome.DesktopExtensionProvider;

            if (this._provider != provider)
            {
                if (this._provider != null) {
                    this._provider.notify["settings"].disconnect (this.on_notify_settings);
                }

                this._provider = provider;

                if (this._provider != null) {
                    this._provider.notify["settings"].connect (this.on_notify_settings);
                }

                this.notify_property ("provider");
                this.update_settings ();
            }
        }

        private void on_notify_provider (GLib.Object    object,
                                         GLib.ParamSpec pspec)
        {
            this.update_provider ();
        }

        private void on_notify_settings (GLib.Object    object,
                                         GLib.ParamSpec pspec)
        {
            this.update_settings ();
        }

        private Adw.Toggle create_toggle (string name,
                                          string label)
        {
            var toggle = new Adw.Toggle ();
            toggle.name = name;
            toggle.label = label;

            return toggle;
        }

        private void setup_appearance_panel ()
                                             requires (this._settings != null)
        {
            var page = (Adw.PreferencesPage) this.current_page;

            // Indicator section
            var indicator_group = new Adw.PreferencesGroup ();
            indicator_group.title = _("Indicator");
            page.add (indicator_group);

            var indicator_type_toggle_group = new Adw.ToggleGroup ();
            indicator_type_toggle_group.homogeneous = true;
            indicator_type_toggle_group.can_shrink = false;
            indicator_type_toggle_group.valign = Gtk.Align.CENTER;
            indicator_type_toggle_group.add (this.create_toggle ("icon", _("Icon")));
            indicator_type_toggle_group.add (this.create_toggle ("text", _("Text")));
            this._settings.bind_property (
                           "indicator-type",
                           indicator_type_toggle_group, "active-name",
                           GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);

            var indicator_type_row = new Adw.ActionRow ();
            indicator_type_row.title = _("Display As");
            indicator_type_row.activatable = false;
            indicator_type_row.add_suffix (indicator_type_toggle_group);
            indicator_group.add (indicator_type_row);

            // Screen Overlay section
            var screen_overlay_group = new Adw.PreferencesGroup ();
            screen_overlay_group.title = _("Screen Overlay");
            page.add (screen_overlay_group);

            var blur_effect_row = new Adw.SwitchRow ();
            blur_effect_row.title = _("Blur Effect");
            this._settings.bind_property (
                           "blur-effect",
                           blur_effect_row, "active",
                           GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
            screen_overlay_group.add (blur_effect_row);

            var dismiss_gesture_row = new Adw.SwitchRow ();
            dismiss_gesture_row.title = _("Dismiss Gesture");
            this._settings.bind_property (
                           "dismiss-gesture",
                           dismiss_gesture_row, "active",
                           GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
            screen_overlay_group.add (dismiss_gesture_row);

            this.indicator_group = indicator_group;
            this.screen_overlay_group = screen_overlay_group;
        }

        public override void handle_panel_changed ()
        {
            if (this._settings == null) {
                return;
            }

            var navigation_page = (Adw.NavigationPage) this.current_navigation_page;

            switch (navigation_page.tag)
            {
                case "appearance":
                    this.setup_appearance_panel ();
                    break;
            }
        }

        private void cleanup ()
        {
            this.indicator_group?.unparent ();
            this.indicator_group = null;

            this.screen_overlay_group?.unparent ();
            this.screen_overlay_group = null;
        }

        public override void dispose ()
        {
            this.cleanup ();

            if (this.desktop_extension != null) {
                this.desktop_extension.notify["provider"].disconnect (this.on_notify_provider);
                this.desktop_extension = null;
            }

            if (this._provider != null) {
                this._provider.notify["settings"].disconnect (this.on_notify_settings);
            }

            this._settings = null;
            this._provider = null;

            base.dispose ();
        }
    }
}
