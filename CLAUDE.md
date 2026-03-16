# SVArcade — Agent Notes

This is the SVArcade project: a Godot arcade launcher showcasing student games from SVA's game design course. It runs as a kiosk on a physical arcade cabinet (NixOS) and also has a GitHub Pages web version.

---

## Current State (March 16, 2026)

### What's Working
- **Menu redesigned**: Dark camo background, red selection borders, white text, semester filter bar (ALL/FALL 2024/FALL 2025/SPRING 2025), scrollable grid with gamepad navigation
- **Context/play screen** restyled to match
- **All 2024 games re-exported** with Godot 4.6.1 (Echo's Tale, Cheesy Escape, Memory, Museum, Sky Theater, Prison) — deployed and running on arcade
- **All 2025 games have PCKs and GameInfo .tres resources** — deployed and showing in menu
- **Auto-update service fixed** — safe.directory issue resolved, pulls on every boot
- **WiFi hotspot profile** ("HMD Fusion") added to NixOS config for portable use
- **Autoload system upgraded** — `metagame.gd` now handles both `.tscn` and `.gd` globals, adds to root, cleans up on quit

### Known Issues — IMMEDIATE
1. **Visual Novel still broken on arcade** — Shows "ddddddddddddddddddd" placeholder text. Root cause: GDScript can't resolve `Game.greed` at parse time for PCK-loaded scripts unless `Game` is a registered autoload. Fix applied: patched `main.gd` to use `@onready var Game = get_node("/root/Game")` and re-exported PCK. **Needs reboot on arcade to test.**
2. **Alice's Tea Party** — 1GB PCK only exists on the arcade machine locally, no source in repo. Too big for GitHub. Untested with 4.6.1.
3. **Momentum (463MB) and Trolley Problem (107MB)** — too big for GitHub, gitignored. Need direct SCP or GitHub Releases to deploy.
4. **Input mapping** — arcade has physical buttons that need mapping. Deferred until physically at SVA with the cabinet.
5. **Thumbnails** — 2025 games use placeholder thumbnails, need real screenshots.

### Autoload/Globals Architecture (IMPORTANT)
The PCK loading system has a fundamental constraint:
- **`.tscn` globals** (e.g. `audio_stream_player.tscn`): Work fine — instantiated and added to root
- **`.gd` script globals** (e.g. `game.gd`): Added to root as nodes, BUT other scripts cannot reference them by autoload name (e.g. `Game.greed`) because GDScript resolves autoload names at compile time, not runtime
- **Workaround**: Game scripts that reference autoloads by name must be patched to use `@onready var Game = get_node("/root/Game")` instead. This has been done for the Visual Novel.
- **Future games with script autoloads will need the same treatment** — check for direct autoload name references in their scripts

### PCK Loading Order (pck_importer.gd)
```
1. ProjectSettings.load_resource_pack(pck_path)
2. Metagame.load_globals(globals)     ← loads BEFORE scene
3. load(main_scene)                    ← scripts parsed here
4. Metagame.load_game(scene, color)   ← change_scene_to_packed
```
Globals are loaded first so nodes are on the tree when `@onready` runs in game scripts.

---

## Arcade Machine

- **NixOS 25.05** with flake at `/home/svarcade/SVArcade-2025/NIX/`
- **Godot 4.6.1** (pulled from nixpkgs-unstable overlay)
- **Auto-update on boot**: `svarcade-update.service` pulls the repo, detects NIX/ changes, rebuilds if needed
- **Kiosk session**: auto-login → X11/Openbox → Godot import + launch in restart loop
- **SSH**: via Tailscale (`svarcade@SVArcade` / `100.101.86.20`), password: `209E23`
- **Claude Code**: installed at `~/.local/bin/claude`
- **WiFi**: SVA network + "HMD Fusion" hotspot (password: fusyzion)

### Auto-update service
`svarcade-update.service` runs before the display manager on each boot:
1. Sets `GIT_CONFIG` env vars to bypass safe.directory (root running on svarcade-owned repo)
2. Waits for network (60s timeout, continues without if offline)
3. `git pull --ff-only` the repo
4. Compares last commit touching `NIX/` before vs after pull
5. If changed → `nixos-rebuild switch` (falls back gracefully on failure)

### Kiosk session
After login, session commands run:
1. Set display resolution (3840x2160 HDMI)
2. Disable screen blanking, hide cursor
3. `godot4 --import` (with display, for full import)
4. `godot4 --path $REPO` in a `while true` restart loop

**Important**: Killing Godot mid-loop skips the import step. Always do a full reboot when deploying changes.

---

## Branch Guide

| Branch | Purpose |
|--------|---------|
| `main` | **Kiosk launcher** — Godot PCK-based project for the physical arcade cabinet |
| `web-exports` | **GitHub Pages site** — static HTML5 web exports |

---

## How the Kiosk Launcher Works (`main` branch)

**Project**: Godot 4.6 (upgraded from 4.3), Forward Plus, fullscreen, main scene: `res://Menus/main_menu.tscn`
**Autoload**: `Metagame` → `res://Utils/metagame.tscn`

### PCK Loading Flow
1. `Menus/GridLoader.tscn` reads `ClassProjects` resources (one per semester)
2. Filter bar lets user filter by semester (ALL/FALL 2024/FALL 2025/SPRING 2025)
3. Spawns one `GameButton` (TextureButton) per game in a scrollable grid
4. User selects → `context.tscn` (CanvasLayer) shows title/authors/Play button
5. Play → `PCKImporter.load_pck(pck_file, main_scene, globals, clear_color)`
6. `Metagame.load_globals()` adds global nodes to root (handles .tscn and .gd)
7. `Metagame.load_game()` calls `get_tree().change_scene_to_packed(scene)`
8. "quit" input action → `unload_globals()` + returns to `res://Menus/main_menu.tscn`

### Key Scripts
- `Utils/metagame.gd` — Singleton: load_game(), load_globals(), unload_globals(), quit handler, idle timeout, music
- `Utils/pck_importer.gd` — Calls ProjectSettings.load_resource_pack(), then globals, then load_game()
- `Menus/grid_loader.gd` — Reads ClassProjects, spawns GameButton nodes, manages semester filter
- `Menus/game_button.gd` — TextureButton with red border on focus
- `Menus/context.gd` — Shows game info, triggers PCK load on Play
- `Menus/idle.gd` — Attract/idle screen, returns to menu on joypad input

### Data Classes
```gdscript
# Classes/GameInfo.gd — one per game
extends Resource
class_name GameInfo
@export var title : String
@export var thumbnail : Texture2D
@export var authors : String
@export var pck_file : String       # e.g. "res://PCKs/memory.pck"
@export var main_scene : String     # res:// scene path inside the PCK
@export var globals : Array[String] # optional autoload scenes/scripts from the PCK
@export var clear_color : Color

# Classes/ClassProjects.gd — collection of games for a semester
extends Resource
class_name ClassProjects
@export var date : String
@export var projects : Array[GameInfo]
```

### Adding a New Game (main branch)
1. Export student's Godot project as `.pck` → place in `PCKs/`
2. Add a thumbnail PNG → `Assets/Thumbnails/`
3. Create a `GameInfo` entry in the appropriate `GameResources/YEAR-SEMESTER.tres`
4. Make sure `globals` includes any autoload scenes the game needs
5. **Important**: main_scene must be a `res://` path (not `uid://`) since UIDs don't resolve across PCK boundaries
6. **Important**: If game scripts reference autoloads by name (e.g. `Game.greed`), patch them to use `@onready var Game = get_node("/root/Game")` instead

---

## NixOS Flake (`NIX/`)

The arcade machine config lives in `NIX/` and is deployed via:
```
nixos-rebuild switch --flake /path/to/repo/NIX#svarcade
```

- `flake.nix` — nixos-25.05 base + Godot 4.6.1 from unstable overlay
- `configuration.nix` — kiosk config: auto-login, X11, Godot restart loop, pipewire, tailscale, SSH, WiFi profiles
- `hardware-configuration.nix` — Intel NUC-like hardware (i915, NVMe, thunderbolt)
- `kiosk-config.nix` — **archived** original manual config (reference only)

---

## 2024 Fall Games

| Title | Authors | PCK | Main Scene | Globals | Status |
|-------|---------|-----|-----------|---------|--------|
| Echo's Tale | Daniel Tiburzi, Qiaofeng Zhang, Yuanqi Zhang | Echo.pck | res://scenes/levels/Opening_Menu.tscn | — | ✅ Re-exported 4.6.1 |
| Memory | Junxin Jiang, Junseok Lim, Cong Zhao | memory.pck | res://menu/main_menu.tscn | audio_stream_player.tscn | ✅ Re-exported 4.6.1 |
| Museum Story | Daibaihe Jiang, Yuanyu Xiang | museum.pck | res://scenes/mian.tscn | audio_stream_player.tscn | ✅ Re-exported 4.6.1 |
| Sky Theater | Abigail Greenberg, Violet Liang | sky-theater.pck | res://story1.tscn | — | ✅ Re-exported 4.6.1 |
| Alice's Tea Party | Alice Li, Dorothy Peng, Natalia Rogers | alice.pck | res://Main.tscn | Bgm.tscn | ⚠️ 1GB PCK only on machine |
| Cheesy Escape | Karen Coto, Zhenyiwan Wang | cheezy.pck | res://main.tscn | — | ✅ Re-exported 4.6.1 |
| A Day in Prison | Darren Arias-Montesino, Dexter Barrett, Kyra Chang, Brian Wu | prison.pck | (in Prison.tres) | — | ✅ Re-exported 4.6.1 |

## 2025 Games

| Title | PCK | Size | Semester | Globals | Status |
|-------|-----|------|----------|---------|--------|
| Horror Game | horror-game.pck | 361K | Fall 2D | Global | ✅ |
| Blooock | blooock.pck | 128K | Fall 2D | — | ✅ |
| Visual Novel | visual-novel.pck | 14M | Fall 2D | game.gd | ⚠️ Autoload fix deployed, needs reboot test |
| The Pet | the-pet.pck | 3.5M | Fall 2D | Global | ✅ |
| Animal Ball | animal-ball.pck | 1.1M | Fall 2D | — | ✅ |
| Trolley Problem | trolley-problem.pck | 107M | Fall Capstone | BGM | ⚠️ Too big for GitHub |
| Momentum | momentum.pck | 463M | Fall Capstone | — | ⚠️ Too big for GitHub |
| Group Chef | group-chef.pck | 7.6M | Spring 2D | — | ✅ |
| Breadknight | breadknight.pck | 16M | Spring 2D | Music | ✅ |
| 2D Game Project | 2d-game.pck | 36M | Spring 2D | AudioStreamPlayer2d, UnderwaterSfx | ✅ |
| Parsec | parsec.pck | 1.7M | Spring Capstone | — | ✅ |
| Breadknight Capstone | breadknight-capstone.pck | 16M | Spring Capstone | Music | ✅ |
| Tao Capstone | tao-capstone.pck | 3.0M | Spring Capstone | — | ✅ |
| Mochi Adventure | mochi.pck | 7.0M | Spring Capstone | — | ✅ |

---

## Asset Locations
- `Assets/Thumbnails/` — game thumbnail PNGs
- `Assets/ARCADE_*.TTF` — arcade-style fonts
- `Assets/bg_camo.png` — dark pixel camo background for menus
- `Menus/` — menu music (DavidKBD Electric Pulse ogg)
- `GameResources/` — `.tres` ClassProjects + GameInfo resources (2024-Fall, 2025-Fall, 2025-Spring)
- `PCKs/` — student game PCK files
- `2024/` — 2024 game source projects
- `projects/` — 2025 game source projects (untracked, not in git)
- `NIX/` — NixOS flake for the arcade machine
