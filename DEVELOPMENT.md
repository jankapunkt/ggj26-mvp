# Tetris Clone - Development Guide

## Code Structure and Architecture

### Game Architecture

The Tetris clone follows a simple node-based architecture using Godot's scene system:

```
Main (Node2D)
├── TetrisGame (Node2D) - Game logic and rendering
└── UI (CanvasLayer) - User interface overlay
    ├── ScoreLabel - Displays current score
    ├── GameOverLabel - Shows game over message
    └── InstructionsLabel - Shows control instructions
```

## Key Concepts and Godot API Usage

### 1. Node Lifecycle

**`_ready()`** - Called once when node enters scene tree
- Used for: Initialization, setting up the game board
- Reference: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-ready

**`_process(delta)`** - Called every frame
- Used for: Game loop, automatic piece falling, continuous updates
- Parameter `delta`: Time elapsed since last frame (in seconds)
- Reference: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-process

**`_input(event)`** - Called when input event occurs
- Used for: Handling keyboard input for game controls
- Reference: https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html

### 2. Custom Drawing

**`_draw()`** - Custom drawing function
- Called when `queue_redraw()` is invoked
- Used for: Rendering the game board, pieces, and grid
- Reference: https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-method-draw-rect

**`draw_rect(rect, color)`** - Draws a filled rectangle
- Parameters:
  - `rect`: Rect2 object defining position and size
  - `color`: Color object
- Reference: https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-method-draw-rect

**`queue_redraw()`** - Schedules a redraw
- Call this when visual state changes
- Reference: https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-method-queue-redraw

### 3. Input Handling

**Input Actions** (defined in project.godot):
- `move_left`: Left arrow or A key
- `move_right`: Right arrow or D key
- `move_down`: Down arrow or S key
- `rotate`: Up arrow, W, or Space key
- `hard_drop`: Enter key

**`Input.is_action_just_pressed(action)`** - Detects single key press
- Returns true only on the frame the key was pressed
- Prevents continuous triggering while held
- Reference: https://docs.godotengine.org/en/stable/classes/class_input.html#class-input-method-is-action-just-pressed

### 4. Data Structures

**Board Representation:**
```gdscript
var board = []  # 2D array of Color objects or null
# board[y][x] = Color or null
# y = 0 is top, y = 19 is bottom
# x = 0 is left, x = 9 is right
```

**Tetromino Shapes:**
```gdscript
# Each shape is a 4x4 array where 1 = filled, 0 = empty
[[0,0,0,0],
 [1,1,1,1],  # I-piece (horizontal line)
 [0,0,0,0],
 [0,0,0,0]]
```

### 5. Collision Detection

**`is_valid_position(x, y, shape)`** - Core collision checking
- Checks if piece position is valid
- Returns false if:
  - Out of bounds (walls or floor)
  - Overlaps with locked pieces
  - Above top (while falling)

### 6. Rotation Logic

**Rotation Algorithm:**
1. Create new 4x4 array for rotated shape
2. Transpose and reverse: `rotated[x][size-1-y] = shape[y][x]`
3. This rotates 90° clockwise

**Wall Kicks:**
- If rotation fails in place, try shifting left/right
- Attempts: 0, -1, +1, -2, +2 positions
- Prevents rotation failure near walls

## Game Flow

### Initialization
1. `_ready()` is called
2. Initialize empty board (10x20 grid)
3. Spawn first random piece

### Game Loop (every frame)
1. `_process(delta)` updates fall timer
2. When timer reaches fall_speed, piece moves down
3. Input is processed via `_input(event)`
4. `queue_redraw()` triggers visual update
5. `_draw()` renders current state

### Piece Lifecycle
1. **Spawn**: Random piece appears at top center
2. **Active**: Player can move/rotate, piece falls automatically
3. **Lock**: When piece can't move down, it locks to board
4. **Clear**: Check for complete lines, clear them
5. **Repeat**: Spawn new piece or game over

### Line Clearing
1. Check each row from bottom to top
2. If row is completely filled:
   - Remove that row from board
   - Insert empty row at top
   - Increment lines cleared counter
3. Award points based on lines cleared

## Code Style Guidelines

### Documentation Comments
Use `##` for documentation comments:
```gdscript
## Brief description of function
## 
## Longer description if needed
## @param param_name: Description
## @return: Description
func my_function(param_name: type) -> return_type:
```

### Type Hints
Always use type hints for better code clarity:
```gdscript
var board: Array = []
var score: int = 0
var current_color: Color = Color.WHITE

func move_piece(dx: int, dy: int) -> bool:
```

### Constants
Use UPPER_CASE for constants:
```gdscript
const BOARD_WIDTH = 10
const CELL_SIZE = 30
```

## Common Modifications

### Changing Game Speed
```gdscript
# In tetris_game.gd
var fall_speed = 1.0  # Seconds between falls
# Lower value = faster game
```

### Adding New Tetromino Shapes
```gdscript
# Add to SHAPES dictionary
const SHAPES = {
	"X": [[0,1,0,0], [1,1,1,0], [0,1,0,0], [0,0,0,0]],  # Plus shape
}

# Add corresponding color
const COLORS = {
	"X": Color(1, 0, 1),  # Magenta
}
```

### Modifying Scoring
```gdscript
# In clear_lines() function
score += [0, 40, 100, 300, 1200][lines_cleared]
# Index 0-4 for 0-4 lines cleared
```

### Changing Board Size
```gdscript
const BOARD_WIDTH = 12  # Wider board
const BOARD_HEIGHT = 22  # Taller board
```

## Testing Checklist

When making changes, verify:
- [ ] Pieces spawn correctly at top center
- [ ] All movements (left, right, down) work
- [ ] Rotation works in all positions
- [ ] Wall kicks function properly
- [ ] Collision detection prevents invalid moves
- [ ] Lines clear correctly
- [ ] Score updates properly
- [ ] Game over triggers when pieces reach top
- [ ] Restart functionality works
- [ ] UI displays correct information

## Debugging Tips

### Print Debugging
```gdscript
print("Current position: ", piece_x, ", ", piece_y)
print("Board state: ", board)
```

### Visual Debugging
```gdscript
# Add to _draw() to visualize collision boxes
draw_rect(Rect2(x, y, width, height), Color(1, 0, 0, 0.3))
```

### Common Issues

**Pieces falling through board:**
- Check `is_valid_position()` logic
- Ensure board coordinates are correct

**Rotation not working:**
- Verify rotation matrix calculation
- Check wall kick attempts

**Lines not clearing:**
- Verify line detection loop
- Check if board.remove_at() works correctly

## Performance Considerations

- Drawing is optimized using `queue_redraw()` only when needed
- Collision checks are minimal (only current piece cells)
- Board updates are in-place where possible

## Future Enhancement Ideas

### Beginner Level
- Add sound effects using AudioStreamPlayer
- Add background music
- Create a pause menu
- Show "next piece" preview

### Intermediate Level
- Implement ghost piece (shows where piece will land)
- Add hold piece functionality
- Create level progression system
- Add particle effects for line clears

### Advanced Level
- Implement T-spin detection and bonus points
- Add multiplayer support
- Create AI opponent
- Add replay system
- Implement different game modes (marathon, sprint, ultra)

## Resources

- [Godot GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Node2D Documentation](https://docs.godotengine.org/en/stable/classes/class_node2d.html)
- [Input Documentation](https://docs.godotengine.org/en/stable/classes/class_input.html)
- [CanvasItem Draw Functions](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html)
- [Tetris Guidelines (Game Design)](https://tetris.wiki/Tetris_Guideline)
