# Sofle ZMK OLED Configuration - Context & Guidelines

## Project Overview
Sofle split keyboard with OLED display support for ZMK firmware, running on Nice!Nano v2 microcontrollers with Zephyr 4.1.0+.

## Zephyr 4.1.0+ Migration Issues & Solutions

### 1. Board Naming Change
**Problem:** ZMK updated its board naming system with Zephyr 4.1.0
- ❌ Old: `nice_nano_v2` (no longer valid)
- ✅ New: `nice_nano//zmk` (variant system)

**Solution Applied:**
- Updated `build.yaml` with new board name
- Updated `build_pikachu.sh` local build script
- Verified with ZMK app boards: `zmk/app/boards/nicekeyboards/nice_nano/`

**Files Modified:**
- `build.yaml`
- `build_pikachu.sh`

### 2. Deprecated Kconfig Symbols
**Problem:** Several config symbols no longer exist in Zephyr 4.1.0
```
CONFIG_CFB=y                              ❌ Not found
CONFIG_DISPLAY=y                          ❌ Deprecated
CONFIG_ZMK_DISPLAY_WORK_QUEUE_DEDICATED=y ❌ N/A
```

**Root Cause:** Sofle shield's `Kconfig.defconfig` automatically configures:
- `CONFIG_I2C=y` (when ZMK_DISPLAY enabled)
- `CONFIG_SSD1306=y` (OLED driver)
- `CONFIG_LVGL` (widget library)

**Solution Applied:**
- Removed deprecated symbols from `config/sofle.conf`
- Kept only `CONFIG_ZMK_DISPLAY=y` as the primary trigger
- Shield's Kconfig handles everything else automatically

**File Modified:**
- `config/sofle.conf`

### 3. West Workspace Initialization
**Problem:** Repository wasn't properly initialized as ZMK config
- No `west.yml` in project root
- No `.west/config` workspace directory

**Solution Applied:**
- Created `west.yml` manifest in project root
- Initialized west workspace: `west init -l config/`
- Ran `west update` to sync all dependencies

**Files Created:**
- `west.yml`
- `.west/config`

### 4. Git Tracking Best Practices
**Problem:** Build artifacts, dependencies, and temporary files were untracked

**Solution Applied:**
- Created comprehensive `.gitignore`
- Excludes: build artifacts, `.west/`, zephyr/, zmk/, IDE files, OS files

**File Created:**
- `.gitignore`

## Zephyr 4.1.0 Key Changes

### Board Variants System
ZMK now uses a new variant system with `//` separator:
- Format: `board_name//variant`
- Example: `nice_nano//zmk`
- Variants can have revisions (1.0.0, 2.0.0, etc.)

### Configuration Auto-Discovery
Shields now automatically configure required drivers based on main config:
```
if ZMK_DISPLAY
    config I2C
        default y
    config SSD1306
        default y
endif
```

Don't manually set these in user config files!

## Build Pipeline Best Practices

### Local Testing
```bash
# Initialize workspace (first time only)
west init -l config/
west update

# Build locally
west build -b nice_nano//zmk -- -DSHIELD=sofle_left

# Or use the provided script
./build_pikachu.sh
```

### GitHub Actions
The workflow automatically uses ZMK's build system and detects boards from `build.yaml`.

## Common Troubleshooting

### Error: "Invalid BOARD"
- Check board name matches ZMK app boards directory
- Use new format: `board_name//variant` (not `board_v2`)

### Error: "Aborting due to Kconfig warnings"  
- Remove undefined `CONFIG_*` symbols
- Let shield's `Kconfig.defconfig` handle driver setup
- Only set `CONFIG_ZMK_DISPLAY=y` for display support

### Error: "West workspace not found"
- Ensure `west.yml` exists in project root
- Run `west init -l config/`
- Run `west update`

## Files Structure
```
.
├── build.yaml                # GitHub Actions matrix config
├── build_pikachu.sh         # Local build script
├── west.yml                 # West manifest (project root)
├── .west/                   # West workspace config (git ignored)
├── config/
│   ├── west.yml            # Redundant manifest (kept for reference)
│   ├── sofle.conf          # ZMK configuration
│   ├── sofle.keymap        # Keymap definition
│   └── sofle.overlay       # Device tree overlay
├── zmk/                     # ZMK firmware (git ignored)
├── zephyr/                  # Zephyr RTOS (git ignored)
└── .gitignore              # Ignore build artifacts & dependencies
```

## Next Steps for Pikachu Animation
The `pikachu_display.c` custom code needs to be integrated properly:
1. Create a custom ZMK module or widget
2. Add to `zmk/app/module` or use external module
3. Reference in west.yml if external
4. Configure via Kconfig if needed

See ZMK documentation on custom widgets and modules.
