/*
 * Copyright (c) 2026 focus-timer contributors
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Gnome
{
    public class ApplicationExtension : Ft.ApplicationExtension
    {
        private Gnome.ShellExtension? shell_extension = null;

        construct
        {
            this.shell_extension = new Gnome.ShellExtension ();
        }

        public override void dispose ()
        {
            this.shell_extension = null;

            base.dispose ();
        }
    }
}
