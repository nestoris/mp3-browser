# 🎵 MP3-Browser for Linux

A modern, lightweight reimagining of the classic file-tree music browser **MP3-Explorer** from the early 2000s. Written in pure **GJS (GNOME JavaScript)** and **GTK3**, this application is designed for speed, minimalism, and seamless integration with local and remote music libraries.

Developed primarily in [Russian](https://github.com/nestoris/mp3-browser-rus), with ongoing efforts to support full localization.

![main window](screenshot.png)

---

## ✨ Key Features & Unique Capabilities

This is not just another music player. It's a powerful **music catalog browser** designed with network libraries in mind.

*   **🌐 Native Support for Remote Libraries (Wi-Fi, DAV, SMB)**
    Built to handle libraries with tens of thousands of tracks over slow connections. The interface never freezes: directories are scanned asynchronously, and ID3 tags are loaded dynamically as you scroll or open folders.
*   **📦 Portable Relative-Path Cache (local or global)**
    Unlike other tools that tie caches to absolute mount paths, MP3-Browser generates portable JSON caches directly inside the music folder whenever it is writable. If the folder is read-only (network mount, GVFS, etc.), caches fall back to `~/.cache/mp3-browser/<md5>-mp3-file-cache.json` and `<md5>-mp3-tag-cache.json`. In both cases a server (e.g. Android/Termux) can scan the library once, and a client (e.g. a Linux PC connected via GVFS) can open the exact same folder by a different path and instantly see all tags without rescanning.
*   **🚀 Standalone CLI Scanner (`mp3-scanner.js`)**
    Need to scan 60,000 tracks on a headless server? The bundled CLI tool can generate tree structures and extract ID3 tags (v1 and v2) without even launching the GUI. The `apply` command lets you update tags *only* for newly added files, saving hours of scanning.
*   **🎛️ Bring Your Own Player**
    The program acts as a commander. Configure custom shell commands for "Play" and "Enqueue" in the settings. Use `mpv`, `vlc`, `termux-media-player`, or any other CLI-capable player. Supports batch playback via automatically generated `.m3u8` temporary files.
*   **🖱️ Thunar-style Multi-Selection & Drag-and-Drop**
    Smooth, native-feeling multiple file selection with proper drag-and-drop support (including custom drag icons showing exactly how many tracks are being moved). Drop tracks directly into playlists, or drop whole folders from the tree onto the playlist list to create new playlists.
*   **📑 Playlists as Bookmarks**
    Simple, file-based playlists stored in JSON. Add, rename, reorder, and remove tracks with ease. Export any playlist to a standard `.m3u8` file for use in other players.
*   **🧠 Smart Sorting**
    Natural numeric sorting for track numbers (1, 2, ..., 9, 10) instead of alphabetical (1, 10, 11, 2). Column widths, column order, window geometry, and **per-playlist sort state** are remembered across sessions.
*   **🖥️ System Tray Icon**
    A GTK status icon provides a one-click way to hide/show the main window without quitting the app.
*   **🐞 Built-in Debugging**
    Run with `--debug` (or `-d`) to have every internal step logged to `~/.cache/mp3-browser/debug.log`.

---

## 🛠️ System Dependencies

The application requires GJS (or CJS) and GTK3. No heavy Electron or web-engine wrappers required.

### Debian / Ubuntu / Linux Mint
```bash
sudo apt update
sudo apt install gjs libgtk-3-0
```

### Fedora
```bash
sudo dnf install gjs gtk3
```

### Arch Linux / Manjaro
```bash
sudo pacman -S gjs gtk3
```

### openSUSE
```bash
sudo zypper install gjs gtk3
```

### 📱 Android (Termux)
You can run the scanner and (with an X11 environment like VNC or Termux:X11) the GUI directly on Android:
```bash
pkg update
pkg install cjs gtk3
ln -s $PREFIX/bin/cjs $PREFIX/bin/gjs
```
*(Note: For playback via Termux, install `termux-api` and configure the `Play` command in the settings to use `termux-media-player play %f`).*

---

## 🚀 Usage Guide

### 1. First Run & Configuration

Launch the browser, optionally pointing it at your music directory:

```bash
./mp3-browser.js /path/to/your/music
```

Any non-option argument is treated as a music root; it is added to the root list on the fly if it isn't already there. Use `--help` (or `-h`) to see usage info.

On the first launch the app creates its configuration files in `~/.config/mp3-browser/`:

*   `config.ini`: Define root folders, player commands, and scanning limits.
*   `window.json`: Remembers window size, panel positions, column widths/order, and last active root.
*   `playlists.json`: Stores your custom playlists (and per-playlist sort state under the `_sort` key).

**Example `config.ini`:**

```ini
[Paths]
Roots=/home/user/Music;/mnt/nas/Music

[Player]
# %f is replaced with the file path or temporary .m3u8 path
Play=mpv --no-video %f
Enqueue=mpv --no-video --append %f
# What Enter / double-click does: "play" or "enqueue"
DefaultAction=play
MultipleTracksUseM3U=true

[Scan]
MaxTrackCount=20000
LogEvery=500
```

*(The GUI settings dialog can also be accessed via `File -> Settings…`.)*

### 2. Portable CLI Caching (The "Killer Feature")

If your music library is on a slow network drive or a server, you can pre-scan it. The scanner creates relative-path caches (`mp3-file-cache.json` and `mp3-tag-cache.json`) right inside the music folder (when writable), so the GUI reads them instantly regardless of the mount point.

**Inspect a single file:**
```bash
gjs mp3-scanner.js test /path/to/track.mp3
```

**Generate a file tree (fast, no ID3 reading):**
```bash
gjs mp3-scanner.js scan /path/to/Music /path/to/Music/mp3-file-cache.json
```

**Read ID3 tags for the whole tree (can take a while):**
```bash
gjs mp3-scanner.js tags /path/to/Music/mp3-file-cache.json /path/to/Music/mp3-tag-cache.json
```

**Update tags ONLY for newly added files (compares tree with existing cache):**
```bash
gjs mp3-scanner.js apply /path/to/Music/mp3-file-cache.json /path/to/Music/mp3-tag-cache.json
```

**All-in-one: scan + apply (reads only files missing from the tag cache):**
```bash
gjs mp3-scanner.js cache /path/to/Music
```

**All-in-one: scan + force re-read of ALL tags (slow!):**
```bash
gjs mp3-scanner.js cacheforce /path/to/Music
```

Run `gjs mp3-scanner.js --help` to see all commands.

When you later open this folder in the GUI (no matter if it's `/home/user/Music` or `/run/user/1000/gvfs/dav:host=.../Music`), the browser will instantly read these JSON files and display your library without any network delays.

### 3. GUI Controls

*   **Folder selector (top)**: Switch between configured roots. The ↻ button reloads the current library — by default it re-uses the tag cache and reads tags only for new files; **SHIFT+click** forces a full re-read (with a confirmation dialog if the library has more than 1000 files).
*   **Left Tree**: Filter directories (check the "Files" box to filter by filenames *and* ID3 tags inside directories). Drag folders onto the playlist list to spawn a new playlist.
*   **Top-Right Table**: Displays tracks. Double-click or press `Enter` to Play or Enqueue (per `DefaultAction`). Right-click for the context menu — Play, Enqueue, Add to playlist, **Sort by…** (including "(no sorting)"), and Refresh.
*   **Bottom-Right Panel**: Manage playlists. Drag tracks from the file table into a playlist, or drag folders from the tree onto the playlist name list to create a new playlist. Right-click for context actions. Column headers sort the playlist (state is remembered per-playlist).
*   **Toolbars**: Use the icons below the tables for quick Play, Enqueue, and Add-to-Playlist actions (supports multiple selection).
*   **System tray icon**: Click to hide/show the main window.

---

## 🐞 Diagnostics

*   **`~/.cache/mp3-browser/scan.log`** — detailed log of the last directory scans (progress per `LogEvery` files, elapsed time).
*   **`~/.cache/mp3-browser/debug.log`** — written only when launched with `--debug` / `-d`; contains GTK/GJS versions, program paths, and internal events.

---

## ⚙️ Technical Details

*   **Language:** GJS (GNOME JavaScript) / CJS (Cinnamon JavaScript)
*   **UI Toolkit:** GTK3
*   **ID3 Parser:** Custom, highly optimized pure-JS parser (supports ID3v1, ID3v2.2/2.3/2.4, UTF-8, UTF-16, Latin-1).
*   **No external dependencies** for tag parsing (no `ffprobe` or `taglib` required).

## 📄 License

*(GPLv3)*
```