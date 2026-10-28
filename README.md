<p align="center">
  <img src="icon-preview.png" width="160" alt="Owl Awake icon">
</p>

<h1 align="center">Owl Awake</h1>

<p align="center">
  One-click menu bar switch that keeps your MacBook fully awake, <b>even with the lid closed</b>.<br>
  Built for AI agents, long downloads, builds and remote sessions.
</p>

---

## What it does

- **Left-click the owl** in the menu bar to switch it on or off.
  - 👀 Eyes open: the Mac never sleeps, with the lid open or closed. No external display, keyboard or charger needed.
  - 😌 Eyes closed: normal sleep behaviour.
- **Right-click** for the menu: Turn On/Off, Open at Login, Remove Permission…, Quit.
- **Quitting doesn't stop it.** The setting lives in macOS (`pmset disablesleep`), not in the app, so it stays on until you switch it off.

Works on macOS 13 Ventura or later, on Apple Silicon and Intel Macs.

## Install

Paste this into **Terminal**:

```bash
curl -fsSL -o /tmp/Owl-Awake.zip https://github.com/Yervand-M/owl-awake/releases/latest/download/Owl-Awake.zip && ditto -x -k /tmp/Owl-Awake.zip /Applications && open "/Applications/Owl Awake.app"
```

The owl appears in your menu bar at the top right of the screen.

<details>
<summary>Prefer downloading by hand?</summary>

1. Download `Owl-Awake.zip` from the [latest release](https://github.com/Yervand-M/owl-awake/releases/latest) and unzip it.
2. Move **Owl Awake.app** to **Applications**.
3. Open it. The app isn't notarised by Apple, so macOS blocks it the first time. Go to **System Settings → Privacy & Security**, scroll down and click **Open Anyway**.

</details>

## First use

The first time you turn it on, macOS asks for your admin password **once**. Owl Awake then installs a one-line permission file, `/etc/sudoers.d/owl-awake`, which lets your user run **only** these two commands without a password:

```
/usr/bin/pmset -a disablesleep 1
/usr/bin/pmset -a disablesleep 0
```

Nothing else is allowed. After that every click switches instantly. **Remove Permission…** in the right-click menu deletes the file and restores normal sleep.

## Pros and cons

| ✅ Pros | ⚠️ Cons |
|---|---|
| Works with the **lid closed and no external display**. `caffeinate` and most "keep awake" apps can't do this. | **Heat:** a closed laptop cools worse. Use it on a hard surface, never in a bag. |
| **One click** on/off, and you can see the state from the owl's eyes. | **Battery:** on battery it runs until empty. Plug in for long runs. |
| Keeps running **after you quit the app** or if it crashes. | That also means **it's easy to forget it's on.** Check the owl before you pack the laptop. |
| Wi-Fi, hotspot, SSH, downloads and agents keep working. | Needs an **admin password once**, and installs a small sudoers rule. |
| Tiny native app with no dependencies, no network access and no tracking. | **Not notarised by Apple,** so a manual download needs "Open Anyway" once. |
| Open source: one Swift file you can read in five minutes. | Turning it off with the lid closed puts the Mac to sleep **immediately**. |

## Turn it off without the app

```bash
sudo pmset -a disablesleep 0
```

## Uninstall

1. Right-click the owl → **Remove Permission…** (this also restores normal sleep).
2. Quit the app and delete **Owl Awake.app** from Applications.

## Build from source

Requires the Xcode Command Line Tools (`xcode-select --install`).

```bash
git clone https://github.com/Yervand-M/owl-awake.git
cd owl-awake
./build.sh
```

This produces `Owl Awake.app` (universal: arm64 + x86_64) and `.build/Owl-Awake.zip`.

| File | Purpose |
|---|---|
| `Sources/main.swift` | Menu bar item, toggle, permission setup |
| `Sources/OwlShape.swift` | The owl drawing, used for the menu bar and app icons |
| `Tools/IconGen/main.swift` | Renders the app icon |
| `build.sh` | Builds, signs (ad-hoc) and zips the app |

## License

MIT. Made by [Tech Creators Lab](https://github.com/Yervand-M).
