# Neovim Config Installation

This config is intended to work across Windows, macOS, and Linux.

## Requirements

Install these tools before first launch:

- Neovim 0.12 or newer
- Git
- Node.js
- npm
- pnpm
- ripgrep
- Zig
- fd
- unzip
- curl

Zig is used as the compiler for Treesitter parsers. Ripgrep and fd improve Telescope search.

## Windows

Recommended with Scoop:

```powershell
scoop install git nodejs pnpm ripgrep zig neovim fd unzip curl
```

Alternative with Winget:

```powershell
winget install --id Neovim.Neovim --exact
winget install --id Git.Git --exact
winget install --id OpenJS.NodeJS.LTS --exact
winget install --id BurntSushi.ripgrep.MSVC --exact
winget install --id zig.zig --exact
```

After installing tools, open a new terminal and verify:

```powershell
nvim --version
git --version
node --version
pnpm --version
rg --version
zig version
```

Config location on Windows:

```text
%LOCALAPPDATA%\nvim
```

## macOS

Recommended with Homebrew:

```bash
brew install neovim git node pnpm ripgrep zig fd unzip curl
```

Verify:

```bash
nvim --version
git --version
node --version
pnpm --version
rg --version
zig version
```

Config location on macOS:

```text
~/.config/nvim
```

## Linux

Use your distro package manager for most tools. Make sure Neovim is 0.12 or newer; distro packages can be outdated.

Ubuntu/Debian base tools:

```bash
sudo apt update
sudo apt install git nodejs npm ripgrep fd-find unzip curl
npm install -g pnpm
```

Install Zig using your package manager, Homebrew on Linux, or the official archive from:

```text
https://ziglang.org/download/
```

Install a recent Neovim from one of:

- Official release archive/AppImage
- Homebrew on Linux
- Bob version manager
- Your distro if it provides Neovim 0.12+

Verify:

```bash
nvim --version
git --version
node --version
pnpm --version
rg --version
zig version
```

Config location on Linux:

```text
~/.config/nvim
```

## First Launch

Open Neovim:

```bash
nvim
```

Then run:

```vim
:Lazy sync
:Mason
```

Mason will install language servers for frontend development, including TypeScript, ESLint, HTML, CSS, JSON, Tailwind CSS, and Emmet.

## Project Formatting

Formatting follows each project. Install formatters and linters in your project when needed:

```bash
pnpm add -D prettier eslint
```

or:

```bash
pnpm add -D @biomejs/biome
```

The config checks for Biome, prettierd, and Prettier depending on filetype and available project tooling.

## Using This Config From A Dotfiles Repo

Recommended repo layout:

```text
dot_configs/
  nvim/
    init.lua
    lazy-lock.json
    lua/
      config/
      plugins/
```

Windows junction:

```powershell
New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\nvim" -Target "$HOME\personal\dot_configs\nvim"
```

macOS/Linux symlink:

```bash
ln -s ~/personal/dot_configs/nvim ~/.config/nvim
```

## Notes

- Do not commit `nvim-data`, Mason packages, or plugin install directories.
- Commit `lazy-lock.json` if you want identical plugin versions across machines.
- Keep external tools available in `PATH` on each OS.
