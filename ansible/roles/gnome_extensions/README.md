# Role: gnome_extensions

Installs GNOME Shell extensions for the current user by downloading official zips from `extensions.gnome.org` and extracting them into `~/.local/share/gnome-shell/extensions/<uuid>/`.

Notes:
- Wayland: logout/login is typically required for newly copied extensions to be registered by the shell.
- X11: you can restart the shell with Alt+F2 → r.

Variables (see `group_vars/all.yml`):
- `gnome_extensions_install_list`: list of entries with either `id`/`pk` (numeric) or `uuid`.
- `gnome_extensions_enable_after_install` (bool): if true, runs `gnome-extensions enable <uuid>` after install.

References and manual commands: see `docs/research/extensions.md`.
