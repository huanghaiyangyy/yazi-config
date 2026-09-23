# Yazi File Manager Configuration & Keybindings

Personal configuration, plugins, custom scripts, and themes for [Yazi (terminal file manager)](https://github.com/sxyazi/yazi).

> **Security Note**: This repository does not contain any API keys, credentials, authentication tokens, or personal secrets. All sensitive paths and credentials should be managed locally.

---

## ⚡ Highlights & Key Features

### 1. 📋 Smart Multi-Target Clipboard (`c c`)
- **Keybinding**: `c c`
- **Behavior**: Powered by the bundled helper `scripts/yazi-clip` via X11 multi-MIME targets (similar to Ubuntu Nautilus / Files):
  - **Terminal / Vim (`Ctrl+Shift+V`)**: Pastes clean absolute path(s) (automatically quoted if spaces exist).
  - **IM apps / Web (`Ctrl+V`)**: Pastes rich **File Cards / Objects** directly into DingTalk, WeChat, Feishu, browser uploaders, etc.

### 2. 📦 Archive & Compression (`e` prefix)
- **`e c`**: Compress selected file(s) (interactive prompt supporting `.zip`, `.tar.gz`, `.tar.xz`, `.7z`, etc.).
- **`e p`**: Encrypted compression with password input.
- **`e e`**: Double-press `e` to safely extract to a folder named after the archive (prevents archive bombs).
- **`e x`**: Extract archive directly into current directory.

### 3. 💾 External Drives & USB Manager (`M` & `g m`)
- **`M`**: Interactive drives manager (powered by `yazi-rs/plugins:mount`), supports navigation, mounting, unmounting, and **safe disk ejection (`e`)**.
- **`g m`**: Instant jump to `/media/huang` (external media root).

### 4. 🚀 Quick Project Navigation (`g` prefix & `;`)
- `g s`: Jump to `sentry_algo`
- `g a`: Jump to `apa_docs/自动泊车`
- `g j`: Jump to `fawvw_apa_env/J02项目资料`
- `g f`: Jump to `fawvw_apa_env`
- `g o`: Jump to `Obsidian_Vault`
- `;` / `` ` ``: Interactive Bunny bookmark drawer with quick key hints and fuzzy search.

### 5. 🕒 Dual Linemode Display (Size + Modified Time)
- **Default Linemode**: Set to `size_mtime` to display both readable file sizes and modification timestamps simultaneously.
- **Smart Date Formatting**: Powered by `linemode-plus.yazi` (today's files display `HH:mm`, previous files display compact `YY-MM-DD`).
- **Keybinding**: Press `m c` to switch to combined mode, or use standard `m s` / `m m` for single attribute modes.

---

## 🔌 Bundled Plugins (`package.toml`)

Managed and pinned via Yazi package manager `ya`:
- `yazi-rs/plugins:mount`: Removable drive and USB manager
- `KKV9/compress`: Archive creation with password & compression level options
- `stelcodes/bunny`: Visual quick-hop drawer
- `dedukun/bookmarks`: Bookmark navigation
- `h-hg/yamb`: Ubuntu-style favorites
- `yazi-rs/plugins:smart-enter`: Context-aware enter (directory enters, file opens)
- `yazi-rs/plugins:git`: Git status icons
- `barbanevosa/linemode-plus`: Dual size & mtime display with compact date formatting
- `XYenon/keep-preferences`: Remembers directory sort & view styles
- `WhoSowSee/mdv-previewer`: Terminal markdown reader
- `llanosrocas/yaziline` & `Rolv-Apneseth/starship`: Status bar themes

---

## 🛠️ Quick Installation

### 1. Clone Repository
```bash
git clone https://github.com/huanghaiyangyy/yazi-config.git ~/.config/yazi-config
```

### 2. Run Setup Script
```bash
cd ~/.config/yazi-config
./setup.sh
```

---

## 📄 License
MIT License.
