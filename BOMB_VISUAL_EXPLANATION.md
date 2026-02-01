# Bomb Detonation - Visual Explanation

## How It Works (Frame by Frame)

```
Frame 0 (t=0s): Player triggers bomb
┌─────────────────────────────────┐
│                                 │
│          Enemy 1                │
│            🔴                   │
│                                 │
│         Enemy 2                 │
│           🔴                    │
│                                 │
│          Player                 │
│            👤●                  │  ← Bomb spawns here
│         (Ability 3)             │     Radius: 0px
│                                 │
└─────────────────────────────────┘

Frame ~30 (t=0.15s): Bomb expanding
┌─────────────────────────────────┐
│                                 │
│          Enemy 1                │
│            🔴                   │
│                                 │
│         Enemy 2                 │
│           🔴                    │
│         ╭─────╮                 │
│        │  👤  │                 │  ← Bomb radius: ~100px
│         ╰─────╯                 │     (semi-transparent blue)
│                                 │
└─────────────────────────────────┘

Frame ~45 (t=0.35s): Near maximum
┌─────────────────────────────────┐
│                                 │
│          Enemy 1                │
│            💥                   │  ← Enemy hit! Shrinking
│      ╭───────────────╮          │
│     │   Enemy 2      │          │
│    │      💥         │          │  ← Enemy hit! Shrinking
│    │                 │          │
│    │       👤        │          │  ← Bomb radius: ~250px
│    │                 │          │
│     ╰───────────────╯           │
│                                 │
└─────────────────────────────────┘

Frame ~50 (t=0.5s): Maximum radius
┌─────────────────────────────────┐
│   ╭──────────────────────────╮  │
│  │                           │  │
│  │                           │  │
│  │                           │  │
│  │                           │  │
│  │                           │  │
│  │           👤             │  │  ← Bomb radius: 350px
│  │                           │  │     (maximum)
│  │                           │  │
│   ╰──────────────────────────╯  │
│                                 │
└─────────────────────────────────┘
Enemies destroyed ☠️

Frame ~51 (t=0.51s): Bomb disappears
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│                                 │
│            👤                   │
│                                 │
│                                 │
└─────────────────────────────────┘
```

## Visual Properties

### Color Scheme
- **Bomb Fill**: `Color(0.0, 0.0, 1.0, 0.3)` - Semi-transparent blue
- **Bomb Outline**: `Color(0.3, 0.3, 1.0, 0.8)` - Brighter blue, more opaque
- **Line Width**: 2 pixels for outline

### Animation
- **Start Radius**: 0 pixels (invisible)
- **End Radius**: 350 pixels
- **Growth Rate**: 700 pixels/second
- **Duration**: ~0.5 seconds
- **Style**: Smooth circular expansion

### Effect on Enemies
When enemy enters bomb radius:
```
Before:  Enemy size = N
After:   Enemy size = N - 10000
Result:  Enemy destroyed (size < KILL_SIZE threshold)
```

## Code Flow

```
Player presses SPACE (Ability 3 selected)
            ↓
  shoot_bomb() called
            ↓
  Bomb instantiated at player.position
            ↓
  Bomb._process(delta) runs every frame:
    - current_radius += 700 * delta
    - Update collision shape
    - queue_redraw()
            ↓
  Enemy enters collision area
            ↓
  _on_area_entered() triggered
            ↓
  Check if enemy group + not already hit
            ↓
  Call enemy.shrink(10000)
            ↓
  Enemy size reduced dramatically
            ↓
  Enemy destroyed (size < KILL_SIZE)
            ↓
  Bomb reaches MAX_RADIUS (350px)
            ↓
  Bomb queue_free() - removed from scene
```

## Integration Points

### Input System
- Triggered by SPACE bar when `current_ability == 3`
- Single shot per press (not rapid fire like Ability 1)
- Requires sufficient gauge to fire

### Collision System
- Uses Godot's Area2D collision detection
- Dynamically growing CircleShape2D
- Checks for "enemy" group membership
- Prevents double-hits with `enemies_hit` array

### Enemy System
- Calls existing `enemy.shrink()` method
- Amount: 10000 (typically kills any enemy)
- Works with enemy size thresholds (KILL_SIZE = 30)
- Triggers enemy_destroyed signal

### Visual System
- Custom `_draw()` method
- Called via `queue_redraw()` each frame
- Renders expanding circle with transparency
- Smooth animation at 60 FPS

## Performance Considerations

- **Lightweight**: Simple circle drawing
- **Efficient**: Single collision shape
- **Short-lived**: ~0.5 second lifetime
- **No physics**: Uses Area2D, not RigidBody2D
- **Optimized**: Removes itself automatically

## Gameplay Impact

**Strategic Use:**
- Area-of-effect damage (unlike single-target bullets)
- Clears multiple enemies simultaneously
- Best used when surrounded
- Gauge cost makes it a tactical choice
- 0.5s window to catch enemies
