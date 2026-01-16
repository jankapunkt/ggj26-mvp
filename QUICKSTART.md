# Quick Start Guide - Tetris Clone

Get up and running in 5 minutes!

## 1. Install Godot (2 minutes)

**Download:** https://godotengine.org/download/

- Get Godot 4.3 or later (Standard version)
- No installation needed - just extract and run!
- Works on Windows, Mac, and Linux

## 2. Open the Project (1 minute)

1. Launch Godot
2. Click **"Import"**
3. Click **"Browse"** and select the `project.godot` file
4. Click **"Import & Edit"**

## 3. Play the Game! (5 seconds)

Press **F5** or click the **▶ Play** button in the top-right corner.

## Controls

```
Move Left:  ←  or  A
Move Right: →  or  D
Move Down:  ↓  or  S
Rotate:     ↑  or  W  or  Space
Hard Drop:  Enter
```

## That's It!

You're now playing Tetris! 🎮

### Want to modify the game?

- All game logic is in `scripts/tetris_game.gd`
- UI elements are in `scripts/ui_controller.gd`
- The main scene is in `scenes/main.tscn`
- Every function has documentation comments

### Need help?

- Read `README.md` for full documentation
- Check `DEVELOPMENT.md` for technical details
- See `CONTRIBUTING.md` for how to contribute

### Common Modifications

**Make the game faster:**
```gdscript
# In scripts/tetris_game.gd, line ~68
var fall_speed = 0.5  # Faster (was 1.0)
```

**Change board size:**
```gdscript
# In scripts/tetris_game.gd, lines ~17-18
const BOARD_WIDTH = 12  # Wider (was 10)
const BOARD_HEIGHT = 22  # Taller (was 20)
```

**Adjust window size:**
```gdscript
# In project.godot, under [display]
window/size/viewport_width=480   # Wider (was 360)
window/size/viewport_height=800  # Taller (was 640)
```

Happy gaming! 🎉
