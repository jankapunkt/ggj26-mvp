# GGJ26 Game - Vertical Chase Game

A vertical scrolling chase game where players avoid enemies while being chased by an entity.

## Game Overview

- **Viewport**: 9:16 (540x960) portrait orientation
- **Perspective**: Player in upper third of screen, map scrolls upward creating infinite runner effect
- **Objective**: Avoid enemies while being chased by an elliptic entity

## Controls

- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **1-5 Keys**: Switch between abilities (implementation pending)
- **Enter**: Restart game (when game over)

## Game Mechanics

### Player
- Positioned in the upper third of the screen
- Can move left and right to avoid enemies
- Has 5 abilities that can be switched (functions to be implemented)

### Chaser Entity
- Elliptic shape that follows the player
- Creates pressure and affects gameplay

### Enemies
Three types of enemies appear randomly:
1. **Triangle** (Orange) - Type 1
2. **Square** (Blue) - Type 2
3. **Hexagon** (Purple) - Type 3

- Enemies spawn at the bottom and move upward
- Only one enemy on screen at a time
- Spawn intervals decrease over time (starts at 3s, minimum 0.5s)
- Touching an enemy triggers game over

### Infinite Scroll
- Background tiles scroll upward continuously
- Creates the illusion of player moving downward
- Player stays in same vertical position

### Game Over
- Triggered when player touches any enemy
- Displays "you dies" message
- Press Enter to restart

## Project Structure

```
ggj26-mvp/
├── project.godot           # Main project configuration
├── icon.svg                # Project icon
├── scenes/
│   ├── main.tscn          # Main game scene
│   └── enemy.tscn         # Enemy scene
├── scripts/
│   ├── game.gd            # Core game logic
│   ├── player.gd          # Player controller
│   ├── chaser.gd          # Chaser entity
│   └── enemy.gd           # Enemy logic
└── tetris/                # Previous prototype
```

## Development Notes

### Core Components

#### game.gd
Main game controller handling:
- Infinite scrolling background
- Enemy spawning system with decreasing intervals
- Collision detection
- Game over state
- Ability switching system

#### player.gd
Player controller:
- Movement handling (left/right)
- Boundary constraints
- Custom drawing (green circle)

#### chaser.gd
Chase entity:
- Smooth following behavior
- Elliptic shape rendering

#### enemy.gd
Enemy behavior:
- Three visual types (triangle, square, hexagon)
- Upward movement
- Collision detection
- Auto-destruction when off-screen

## Future Enhancements

- Implement specific functions for the 5 abilities
- Add scoring system
- Add visual effects
- Add sound effects and music
- Add difficulty levels
- Add power-ups
