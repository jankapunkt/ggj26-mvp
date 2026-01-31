# Ability System Implementation

## Overview
This document describes the updated ability system implemented for the GGJ26 vertical chase game.

## Ability Mechanics

### Ability Color Mapping
Each ability corresponds to a specific color:

1. **Ability 1 - Red** (RGB: 1.0, 0.0, 0.0, 0.1)
2. **Ability 2 - Green** (RGB: 0.0, 1.0, 0.0, 0.1) - **Rapid Fire** capability
3. **Ability 3 - Blue** (RGB: 0.0, 0.0, 1.0, 0.1)
4. **Ability 4 - White** (RGB: 1.0, 1.0, 1.0, 0.1)

### Shooting Mechanics

#### Ability 2 - Rapid Fire
- **Trigger**: Hold SPACE key to shoot continuously
- **Fire Rate**: 10 shots per second (configurable via `ability_2_fire_rate` export variable)
- **Throttling**: Uses delta time for consistent fire rate across different frame rates
- **Control**: Release SPACE to stop shooting

#### Other Abilities
- **Trigger**: Press SPACE once to shoot
- **Behavior**: Single shot per key press

### Win Conditions
Each ability wins against 2 specific enemy types:

- **Ability 1 (Violet)** wins against **Enemies 2 & 4** (Yellow & Green)
- **Ability 2 (Yellow)** wins against **Enemies 3 & 5** (Red & Blue)
- **Ability 3 (Red)** wins against **Enemies 4 & 1** (Green & Violet)
- **Ability 4 (Green)** wins against **Enemies 5 & 2** (Blue & Yellow)
- **Ability 5 (Blue)** wins against **Enemies 1 & 3** (Violet & Red)

This creates a rock-paper-scissors-style mechanic where strategic ability selection is crucial.

## Enemy Types

The game now spawns 5 different enemy types (previously 3), all rendered as circles with different colors:

1. **Enemy 1 - Circle (Violet)**
2. **Enemy 2 - Circle (Yellow)**
3. **Enemy 3 - Circle (Red)**
4. **Enemy 4 - Circle (Green)**
5. **Enemy 5 - Circle (Blue)**

Each enemy uses the same color as its corresponding ability number.

## Visual Feedback

### Player Color
The player's color dynamically changes based on the currently selected ability:
- Press keys 1-5 to switch abilities
- The player circle immediately changes to the ability's color
- The ability label shows both the ability number and name (e.g., "Ability 1: Violet")

### Enemy Color
Each enemy type is rendered in its corresponding color:
- Enemy 1 (Triangle) = Violet
- Enemy 2 (Square) = Yellow
- Enemy 3 (Hexagon) = Red
- Enemy 4 (Pentagon) = Green
- Enemy 5 (Circle) = Blue

## Collision System

### Winning Collision
When the player collides with an enemy and has the winning ability selected:
- The enemy is destroyed immediately
- The player continues playing (does not die)
- A new enemy spawns after the regular interval

### Losing Collision
When the player collides with an enemy without the winning ability:
- Game over is triggered
- "you dies" message is displayed
- Player can press ENTER to restart

## Implementation Details

### Files Modified

1. **scripts/game.gd**
   - Added `ability_config` dictionary with color and win condition mappings
   - Modified `spawn_enemy()` to generate 5 enemy types instead of 3
   - Updated `check_collision_with_enemy()` to check win conditions
   - Added `update_player_color()` to change player appearance
   - Added `does_player_win()` to determine collision outcomes
   - Added `get_enemy_color()` to provide colors to enemies

2. **scripts/player.gd**
   - Added `current_color` variable
   - Modified `_draw()` to use dynamic color based on ability
   - **NEW**: Added `ability_2_fire_rate` export variable (default: 10 shots/second)
   - **NEW**: Added `time_since_last_shot` timer for throttling
   - **NEW**: Implemented rapid fire logic in `_physics_process()`:
     - For Ability 2: Uses `Input.is_action_pressed()` to detect held space bar
     - Calculates fire interval based on fire rate and delta time
     - Ensures consistent fire rate across different frame rates
     - For other abilities: Uses `Input.is_action_just_pressed()` for single shots

3. **scripts/enemy.gd**
   - Updated `_draw()` to render all enemy types as circles
   - Added `get_enemy_color()` to retrieve color from game controller
   - Removed shape-specific drawing functions (triangle, square, hexagon, pentagon)
   - Added `draw_circle_enemy()` for unified circle rendering with color

## Controls

- **A/D or Arrow Keys**: Move left/right
- **SPACE**: Shoot (Single shot for most abilities, hold for rapid fire with Ability 2)
- **1**: Switch to Ability 1 (Red)
- **2**: Switch to Ability 2 (Green) - Rapid Fire mode
- **3**: Switch to Ability 3 (Blue)
- **4**: Switch to Ability 4 (White)
- **Enter**: Restart game (when game over)

## Strategic Gameplay

Players must:
1. Observe the color of incoming enemies
2. Quickly switch to the appropriate ability to counter the enemy
3. Time ability switches to match the enemy type before collision
4. Manage the increasing spawn rate of enemies

The system creates a strategic element where players need to react quickly and choose the right ability to survive.
