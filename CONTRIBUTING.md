# Contributing to Tetris Clone

Thank you for your interest in contributing to this Tetris clone project! This guide will help you get started with collaborative development.

## Getting Started

### Setting Up Your Development Environment

1. **Install Godot Engine 4.3+**
   - Download from: https://godotengine.org/download/
   - Choose the standard version (not .NET version)
   - Extract and run the Godot editor

2. **Clone and Open the Project**
   ```bash
   git clone <repository-url>
   cd ggj26-mvp
   ```
   - Open Godot
   - Click "Import"
   - Select the `project.godot` file
   - Click "Import & Edit"

3. **Understand the Project Structure**
   - Read `README.md` for project overview
   - Read `DEVELOPMENT.md` for technical details
   - Explore the code with comments as guides

## Development Workflow

### Before Making Changes

1. **Create a new branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Test the current game**
   - Run the game (F5 in Godot)
   - Verify everything works
   - Note any existing issues

### Making Changes

1. **Write clean, documented code**
   - Follow existing code style
   - Add `##` documentation comments
   - Use type hints for variables and functions
   - Keep functions small and focused

2. **Test your changes frequently**
   - Use F5 to run the game
   - Test all affected functionality
   - Check for edge cases

3. **Commit regularly**
   ```bash
   git add .
   git commit -m "Brief description of changes"
   ```

### Submitting Changes

1. **Test thoroughly**
   - Play the game extensively
   - Test all controls
   - Verify score calculations
   - Check edge cases (game over, line clears, etc.)

2. **Update documentation**
   - Update README.md if adding features
   - Update DEVELOPMENT.md if changing architecture
   - Add comments to new code

3. **Create a pull request**
   ```bash
   git push origin feature/your-feature-name
   ```
   - Open a PR on GitHub
   - Describe what you changed and why
   - Reference any related issues

## Code Style Guidelines

### GDScript Style

```gdscript
# Use type hints
var score: int = 0
var board: Array = []

# Document functions
## Moves the piece by the specified offset
## @param dx: Horizontal movement (-1 left, 1 right)
## @param dy: Vertical movement (1 down)
## @return: True if move succeeded
func move_piece(dx: int, dy: int) -> bool:
	# Implementation
	pass

# Use meaningful variable names
var piece_x: int = 0  # Good
var px: int = 0  # Avoid

# Constants in UPPER_CASE
const BOARD_WIDTH = 10
const CELL_SIZE = 30
```

### Scene Organization

- Keep scenes in `scenes/` folder
- Keep scripts in `scripts/` folder
- Use descriptive names: `tetris_game.gd`, not `game.gd`
- One script per file

## What to Contribute

### Good First Contributions

- **Bug fixes**: Fix issues you encounter while playing
- **Documentation**: Improve comments or guides
- **Code cleanup**: Refactor complex functions
- **Visual improvements**: Better colors, effects, UI

### Feature Ideas

**Easy:**
- Add pause functionality
- Show lines cleared count
- Add different color schemes
- Improve UI layout

**Medium:**
- Add "next piece" preview
- Implement hold piece feature
- Add levels with increasing speed
- Create a start menu

**Advanced:**
- Add sound effects and music
- Implement particle effects
- Create different game modes
- Add high score persistence

## Testing Your Changes

### Manual Testing Checklist

- [ ] Game starts without errors
- [ ] All pieces spawn correctly
- [ ] Movement keys work (left, right, down)
- [ ] Rotation works in all positions
- [ ] Pieces lock when reaching bottom
- [ ] Lines clear correctly
- [ ] Score updates properly
- [ ] Game over triggers correctly
- [ ] Restart works properly
- [ ] UI displays correctly

### Edge Cases to Test

- Rotating near walls
- Rotating near other pieces
- Clearing multiple lines at once
- Clearing lines near the top
- Spawning when spawn area is blocked
- Hard drop functionality

## Common Issues and Solutions

### "Scene failed to load"
- Check that paths in .tscn files are correct
- Ensure all referenced scripts exist

### "Invalid get index"
- Check array bounds before accessing
- Verify variables are initialized

### Pieces behaving strangely
- Print debug info: `print("Debug: ", variable)`
- Check collision detection logic
- Verify coordinate system (y increases downward)

### Changes not appearing
- Save all files (Ctrl+S)
- Reload the scene (Ctrl+R)
- Check console for errors

## Getting Help

### Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [Godot Q&A](https://ask.godotengine.org/)
- [Godot Discord](https://discord.gg/godotengine)

### In This Project

- Check `DEVELOPMENT.md` for technical details
- Look at existing code for examples
- Comment on issues for clarification
- Ask questions in pull requests

## Code Review Process

When reviewing others' code:

1. **Test the changes**
   - Pull the branch and run the game
   - Verify functionality works as described

2. **Check code quality**
   - Is it readable and well-documented?
   - Does it follow existing patterns?
   - Are there any obvious bugs?

3. **Provide constructive feedback**
   - Point out issues clearly
   - Suggest improvements
   - Acknowledge good work

## Versioning

This project follows semantic versioning:
- Major: Breaking changes or complete rewrites
- Minor: New features, backward compatible
- Patch: Bug fixes

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## Questions?

Feel free to:
- Open an issue for discussion
- Ask in pull request comments
- Contact project maintainers

Happy coding! 🎮
