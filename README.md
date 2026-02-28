# WezTerm Config (noidilin fork)

A personal fork of Kevin Silvester's WezTerm setup, now significantly diverged from upstream.

- Original upstream: [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config)
- Visual inspiration: [GrzegorzKozub/wezterm](https://github.com/GrzegorzKozub/wezterm)

![screenshot](./.github/screenshots/wezterm.gif)

---

## Why this fork exists

This repo started from upstream, then evolved into a different setup focused on:

- custom statusline and tab rendering
- a custom monochrome-first palette (`achroma`)
- leader-driven key tables for pane/tab/workspace workflows

---

## Current Features

### Newly added

- **Custom tab title renderer**
  - Process/CWD-aware tab titles.
  - Visual states for active/inactive/unseen output.
  - Bell, zoom, and progress indicators.
- **Custom status areas**
  - Left status: mode, workspace, domain, admin/WSL context.
  - Right status: memory (via Starship module) + battery.
- **Leader + key tables workflow**
  - Dedicated tables for `move`, `resize`, `view`, and `mux`.
  - Smart pane navigation that cooperates with Neovim smart-splits.

### Support by upstream

- **Modular config pipeline**: config composed by options from small focused modules.
- **Launch menu**: OS-specific `default_prog` and launch menu entries.
- **Domain integration**: WSL/SSH domain handling for cross-platform workflows.
- **GPU adapter**: Automatically picks preferred backend per platform for `WebGpu`.
- **Backdrop utility**: image helper exists in `utils/backdrops.lua`.

---

## Installation

If you already have a WezTerm config, back it up first.

```sh
git clone git@github.com:noidilin/wezterm.git ~/.config/wezterm
```

> [!NOTE] Requirements:
>
> - **Nerd Font**: (`CommitMono Nerd Font Mono` in current config)
> - Optional:
>   - **Starship** for memory usage in right status (`starship module memory_usage`)
>   - **Nu shell** if you want to keep default launch behavior on macOS/Windows

---

## Keybinding Overview

Leader key:

- `LEADER = CTRL+q` (timeout 3000ms)

Examples:

- `F1` - copy mode
- `F3` - command palette
- `F4` - launcher (menu/domains)
- `F5` - workspace launcher
- `F6` - tab launcher
- `LEADER + -` - split vertical
- `LEADER + \` - split horizontal
- `LEADER + x` - close pane
- `LEADER + z` - zoom pane
- `LEADER + c` - new tab
- `LEADER + &` - close tab
- `LEADER + m` - move key table
- `LEADER + s` - resize key table
- `LEADER + v` - view/scroll key table
- `LEADER + y` - copy mode
- `LEADER + f` - search
- `LEADER + w` - mux key table

For full details, see `config/bindings.lua`.

---

## Customization

### Repo Layout

```text
config/   # wezterm option modules
events/   # runtime event handlers (status, tabs, startup)
utils/    # helpers (cells, backdrops, gpu adapter, platform, math)
icon-alt/ # optional macOS alternative app icon assets
```

### Key Entry Point

Start here if you want to adapt this config to your machine:

- `config/custom.lua` - common personal values (status label, shell, workspace, Starship, fonts)
- `config/launch-menu.lua` - default shell + launch menu per OS
- `config/domains.lua` - SSH/WSL/unix domains
- `config/fonts.lua` - font family, size, line height
- `config/appearance.lua` - theme, tab bar/window, GPU front-end
- `config/theme.lua` - active color scheme and palette mapping
- `config/bindings.lua` - all keybindings and key tables

### Quick Custom Recipes

Edit only `config/custom.lua` for high-frequency personalization:

- Status label in left status: set `name.status_label`
- Startup workspace: set `name.workspace`
- SSH default user path (`/home/<name>`): set `name.ssh_user`
- WSL default user + path (`/home/<name>`): set `name.wsl_user`
- Default shell executable per OS: set `executable.default_shell.windows|mac|linux`
- Starship executable per OS (right status memory module): set `executable.starship.windows|mac|linux`
- Font family and per-OS sizing: set `font.family`, `font.size.*`, `font.line_height.*`

---

## References

- [Original upstream: KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config)
- [Inspiration: GrzegorzKozub/wezterm](https://github.com/GrzegorzKozub/wezterm)
- [WezTerm tab formatting discussion](https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614)
- [WezTerm tab formatting follow-up](https://github.com/wez/wezterm/discussions/628#discussioncomment-5942139)
- [catppuccin/wezterm](https://github.com/catppuccin/wezterm)
- [rxi/lume](https://github.com/rxi/lume)

---

## License

MIT - see `LICENSE`.
