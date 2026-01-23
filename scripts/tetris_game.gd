extends Node2D
## Main Tetris Game Controller
##
## This script manages the core Tetris game logic including:
## - Game board state and rendering
## - Tetromino (game piece) spawning and movement
## - Collision detection
## - Line clearing and scoring
## - Game over detection
##
## References:
## - Node2D: https://docs.godotengine.org/en/stable/classes/class_node2d.html
## - Input handling: https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html

# Constants for game configuration
const BOARD_WIDTH = 10
const BOARD_HEIGHT = 20
const CELL_SIZE = 30

# sounds
@onready var sfx_points: AudioStreamPlayer = $"../sfx_points"
@onready var sfx_game_over: AudioStreamPlayer = $"../sfx_game-over"
@onready var sfx_rotate: AudioStreamPlayer = $"../sfx_rotate"
@onready var sfx_landing: AudioStreamPlayer = $"../sfx_landing"
@onready var background: AudioStreamPlayer = $"../background_music"


# Tetromino shapes defined as 2D arrays
# Each shape is a 4x4 grid where 1 represents a filled cell
const SHAPES = {
	"I": [[0,0,0,0], [1,1,1,1], [0,0,0,0], [0,0,0,0]],
	"O": [[1,1,0,0], [1,1,0,0], [0,0,0,0], [0,0,0,0]],
	"T": [[0,1,0,0], [1,1,1,0], [0,0,0,0], [0,0,0,0]],
	"S": [[0,1,1,0], [1,1,0,0], [0,0,0,0], [0,0,0,0]],
	"Z": [[1,1,0,0], [0,1,1,0], [0,0,0,0], [0,0,0,0]],
	"J": [[1,0,0,0], [1,1,1,0], [0,0,0,0], [0,0,0,0]],
	"L": [[0,0,1,0], [1,1,1,0], [0,0,0,0], [0,0,0,0]]
}

# Colors for each tetromino type
const COLORS = {
	"I": Color(0, 1, 1),      # Cyan
	"O": Color(1, 1, 0),      # Yellow
	"T": Color(0.5, 0, 1),    # Purple
	"S": Color(0, 1, 0),      # Green
	"Z": Color(1, 0, 0),      # Red
	"J": Color(0, 0, 1),      # Blue
	"L": Color(1, 0.5, 0)     # Orange
}

# Game state variables
var board = []
var current_piece = null
var current_shape = []
var current_color = Color.WHITE
var piece_x = 0
var piece_y = 0
var score = 0
var game_over = false

# Timing variables
var fall_timer = 0.0
var default_fall_speed = 1.0  # Default falling speed
var slow_motion_speed = 2.5  # Slower falling speed when slow motion is active
var fall_speed = default_fall_speed  # Current falling speed (seconds between automatic falls)
var is_slow_motion_active = false  # Track slow motion state

# UI reference
var ui_controller = null

## Called when the node enters the scene tree for the first time.
## Initializes the game board and spawns the first piece.
## Reference: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-ready
func _ready():
	# Get reference to UI controller
	ui_controller = get_node("../UI")
	initialize_board()
	spawn_piece()
	update_ui()
	background.volume_linear = 0.25
	background.play()
	sfx_landing.volume_linear = 0.5

## Initializes the game board as a 2D array filled with null values.
## The board represents the play area where pieces accumulate.
func initialize_board():
	board = []
	for y in range(BOARD_HEIGHT):
		var row = []
		for x in range(BOARD_WIDTH):
			row.append(null)
		board.append(row)

## Spawns a new random tetromino piece at the top center of the board.
## If the spawn position is blocked, triggers game over.
func spawn_piece():
	var shape_keys = SHAPES.keys()
	var random_key = shape_keys[randi() % shape_keys.size()]
	
	current_piece = random_key
	current_shape = SHAPES[random_key]
	current_color = COLORS[random_key]
	
	piece_x = BOARD_WIDTH / 2 - 2
	piece_y = 0
	
	if not is_valid_position(piece_x, piece_y, current_shape):
		game_over = true
		print("Game Over! Final Score: ", score)
		sfx_game_over.play()
		if ui_controller:
			ui_controller.show_game_over()

## Called every frame. Delta is the elapsed time since the previous frame.
## Handles automatic piece falling and input processing.
## Reference: https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-process
func _process(delta):
	if game_over:
		return
	
	# Check if slow motion state changed
	var slow_motion_pressed = Input.is_action_pressed("slow_motion")
	if slow_motion_pressed != is_slow_motion_active:
		is_slow_motion_active = slow_motion_pressed
		fall_speed = slow_motion_speed if is_slow_motion_active else default_fall_speed
	
	# Automatic falling
	fall_timer += delta
	if fall_timer >= fall_speed:
		fall_timer = 0.0
		move_down()
	
	# Force redraw to update visuals
	queue_redraw()

func toggle_pause():
	var tree = get_tree()
	tree.paused = !tree.paused

## Handles player input for moving and rotating pieces.
## Uses Input.is_action_just_pressed() to detect single key presses.
## Reference: https://docs.godotengine.org/en/stable/classes/class_input.html#class-input-method-is-action-just-pressed
func _input(event):
	if game_over:
		if event.is_action_pressed("ui_accept"):
			reset_game()
		return
	
	if Input.is_action_just_pressed("move_left"):
		move_piece(-1, 0)
	elif Input.is_action_just_pressed("move_right"):
		move_piece(1, 0)
	elif Input.is_action_just_pressed("move_down"):
		move_down()
	elif Input.is_action_just_pressed("rotate"):
		rotate_piece()
	elif Input.is_action_just_pressed("hard_drop"):
		hard_drop()

## Attempts to move the current piece by the specified offset.
## Returns true if the move was successful, false otherwise.
func move_piece(dx: int, dy: int) -> bool:
	var new_x = piece_x + dx
	var new_y = piece_y + dy
	
	if is_valid_position(new_x, new_y, current_shape):
		piece_x = new_x
		piece_y = new_y
		return true
	return false

## Moves the current piece down one row.
## If it can't move down, locks the piece and spawns a new one.
func move_down():
	if not move_piece(0, 1):
		lock_piece()
		var lines_cleared = clear_lines()
		spawn_piece()
		# Play points sound if lines were cleared, otherwise landing sound
		if lines_cleared > 0:
			sfx_points.play()
		else:
			sfx_landing.play()

## Instantly drops the current piece to the lowest valid position.
func hard_drop():
	while move_piece(0, 1):
		pass
	lock_piece()
	var lines_cleared = clear_lines()
	spawn_piece()
	# Play points sound if lines were cleared, otherwise landing sound
	if lines_cleared > 0:
		sfx_points.play()
	else:
		sfx_landing.play()
	

## Rotates the current piece 90 degrees clockwise.
## Uses wall kick logic if the rotation would collide.
func rotate_piece():
	var rotated = rotate_shape(current_shape)
	
	# Try rotating in place
	if is_valid_position(piece_x, piece_y, rotated):
		current_shape = rotated
		return
	
	# Try wall kicks (move left or right to fit rotation)
	for kick_x in [-1, 1, -2, 2]:
		if is_valid_position(piece_x + kick_x, piece_y, rotated):
			piece_x += kick_x
			current_shape = rotated
			return

## Rotates a shape matrix 90 degrees clockwise.
## Returns the rotated shape as a new 2D array.
func rotate_shape(shape: Array) -> Array:
	var size = shape.size()
	var rotated = []
	
	for i in range(size):
		var row = []
		for j in range(size):
			row.append(0)
		rotated.append(row)
	
	for y in range(size):
		for x in range(size):
			rotated[x][size - 1 - y] = shape[y][x]
	
	sfx_rotate.play()
	return rotated

## Checks if a piece at the given position with the given shape is valid.
## Returns false if it would collide with walls, floor, or locked pieces.
func is_valid_position(x: int, y: int, shape: Array) -> bool:
	for sy in range(shape.size()):
		for sx in range(shape[sy].size()):
			if shape[sy][sx] == 0:
				continue
			
			var board_x = x + sx
			var board_y = y + sy
			
			# Check bounds
			if board_x < 0 or board_x >= BOARD_WIDTH:
				return false
			if board_y >= BOARD_HEIGHT:
				return false
			if board_y < 0:
				continue
			
			# Check collision with locked pieces
			if board[board_y][board_x] != null:
				return false
	
	return true

## Locks the current piece into the board by storing its color in the board array.
func lock_piece():
	for sy in range(current_shape.size()):
		for sx in range(current_shape[sy].size()):
			if current_shape[sy][sx] == 1:
				var board_x = piece_x + sx
				var board_y = piece_y + sy
				if board_y >= 0 and board_y < BOARD_HEIGHT:
					board[board_y][board_x] = current_color

## Checks for complete lines and clears them, updating the score.
## Complete lines are removed and upper rows fall down.
## Returns the number of lines cleared.
func clear_lines() -> int:
	var lines_cleared = 0
	
	for y in range(BOARD_HEIGHT - 1, -1, -1):
		var is_full = true
		for x in range(BOARD_WIDTH):
			if board[y][x] == null:
				is_full = false
				break
		
		if is_full:
			lines_cleared += 1
			# Remove the line
			board.remove_at(y)
			# Add empty line at top
			var new_row = []
			for x in range(BOARD_WIDTH):
				new_row.append(null)
			board.insert(0, new_row)
	
	# Update score (classic Tetris scoring)
	if lines_cleared > 0:
		score += [0, 40, 100, 300, 1200][lines_cleared]
		print("Lines cleared: ", lines_cleared, " | Score: ", score)
		update_ui()
	
	return lines_cleared

## Custom drawing function to render the game board and current piece.
## Reference: https://docs.godotengine.org/en/stable/classes/class_canvasitem.html#class-canvasitem-method-draw-rect
func _draw():
	# Draw background
	draw_rect(Rect2(0, 0, BOARD_WIDTH * CELL_SIZE, BOARD_HEIGHT * CELL_SIZE), Color(0.1, 0.1, 0.1))
	
	# Draw grid lines
	for x in range(BOARD_WIDTH + 1):
		draw_line(Vector2(x * CELL_SIZE, 0), Vector2(x * CELL_SIZE, BOARD_HEIGHT * CELL_SIZE), Color(0.3, 0.3, 0.3), 1)
	for y in range(BOARD_HEIGHT + 1):
		draw_line(Vector2(0, y * CELL_SIZE), Vector2(BOARD_WIDTH * CELL_SIZE, y * CELL_SIZE), Color(0.3, 0.3, 0.3), 1)
	
	# Draw locked pieces
	for y in range(BOARD_HEIGHT):
		for x in range(BOARD_WIDTH):
			if board[y][x] != null:
				draw_cell(x, y, board[y][x])
	
	# Draw current piece
	if current_piece != null:
		for sy in range(current_shape.size()):
			for sx in range(current_shape[sy].size()):
				if current_shape[sy][sx] == 1:
					var draw_x = piece_x + sx
					var draw_y = piece_y + sy
					if draw_y >= 0:
						draw_cell(draw_x, draw_y, current_color)
	
	# Draw game over text
	if game_over:
		var center_x = BOARD_WIDTH * CELL_SIZE / 2
		var center_y = BOARD_HEIGHT * CELL_SIZE / 2
		draw_rect(Rect2(center_x - 100, center_y - 40, 200, 80), Color(0, 0, 0, 0.8))

## Draws a single cell at the given board coordinates with the specified color.
func draw_cell(x: int, y: int, color: Color):
	var rect = Rect2(x * CELL_SIZE + 1, y * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2)
	draw_rect(rect, color)
	# Add a lighter border for 3D effect
	var border_color = color.lightened(0.3)
	draw_rect(Rect2(x * CELL_SIZE + 1, y * CELL_SIZE + 1, CELL_SIZE - 2, 2), border_color)
	draw_rect(Rect2(x * CELL_SIZE + 1, y * CELL_SIZE + 1, 2, CELL_SIZE - 2), border_color)

## Resets the game state for a new game.
func reset_game():
	initialize_board()
	score = 0
	game_over = false
	fall_timer = 0.0
	spawn_piece()
	update_ui()
	if ui_controller:
		ui_controller.hide_game_over()

## Updates the UI with current game state.
func update_ui():
	if ui_controller:
		ui_controller.update_score(score)
