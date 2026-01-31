extends Node2D

# Game configuration
const VIEWPORT_WIDTH = 1080
const VIEWPORT_HEIGHT = 1920
const PLAYER_Y_POSITION = VIEWPORT_HEIGHT / 3  # Upper third

# Scrolling configuration
const SCROLL_SPEED = 100.0  # Pixels per second

# Enemy spawn configuration
var spawn_interval = 3.0  # Start with 3 seconds
var min_spawn_interval = 0.5  # Minimum 0.5 seconds
var spawn_decrease_rate = 0.1  # Decrease by 0.1 seconds each spawn

# Game state
var game_over = false
var scroll_offset = 0.0
var current_enemy = null
var time_since_last_spawn = 0.0
var current_ability = 1  # Default ability 1

# Ability system configuration
# Maps ability number to: [color, [enemies it wins against]]
var ability_config = {
	0: {"color": Color(1.0, 1.0, 1.0), "name": "White", "wins_against": []},
	1: {"color": Color(0.58, 0.0, 0.83), "name": "Violet", "wins_against": [2, 4]},  # Violet wins 2,4
	2: {"color": Color(1.0, 1.0, 0.0), "name": "Yellow", "wins_against": [3, 5]},    # Yellow wins 3,5
	3: {"color": Color(1.0, 0.0, 0.0), "name": "Red", "wins_against": [4, 1]},       # Red wins 4,1
	4: {"color": Color(0.0, 1.0, 0.0), "name": "Green", "wins_against": [5, 2]},     # Green wins 5,2
	5: {"color": Color(0.0, 0.0, 1.0), "name": "Blue", "wins_against": [1, 3]},       # Blue wins 1,3
}

# Node references
@onready var player = $Player
@onready var chaser = $Chaser
@onready var game_over_screen = $CanvasLayer/GameOverScreen
@onready var ability_label = $CanvasLayer/AbilityLabel

#-------------------------------------------------------------------------------
# Game Loop
#-------------------------------------------------------------------------------
func _ready():
	game_over_screen.visible = false
	update_ability_display()
	init_player()
	set_chaser_position()

func _process(delta):
	if game_over:
		if Input.is_action_just_pressed("ui_accept"):
			restart_game()
		return
	
	# Handle ability switching
	for i in range(1, 6):
		if Input.is_action_just_pressed("ability_%d" % i):
			current_ability = i
			update_ability_display()
			update_player_color()
	
	# Update scroll effect
	scroll_offset += SCROLL_SPEED * delta
	queue_redraw()
	
	# Update chaser to follow player
	update_chaser()
	
	# Handle enemy spawning
	time_since_last_spawn += delta
	if time_since_last_spawn >= spawn_interval and current_enemy == null:
		spawn_enemy()
		time_since_last_spawn = 0.0

func trigger_game_over():
	game_over = true
	game_over_screen.visible = true

func restart_game():
	get_tree().reload_current_scene()
	
#-------------------------------------------------------------------------------
# Chaser
#-------------------------------------------------------------------------------

func set_chaser_position():
	chaser.position = Vector2(VIEWPORT_WIDTH / 2, 0)

func update_chaser():
	# Keep chaser static above player (fixed offset, not following)
	# chaser.position = Vector2(player.position.x, player.position.y - 100)
	chaser.queue_redraw()

#-------------------------------------------------------------------------------
# Enemies
#-------------------------------------------------------------------------------

func spawn_enemy():
	# Random enemy type (1-5)
	var enemy_type = randi() % 5 + 1
	var enemy = preload("res://scenes/enemy.tscn").instantiate()
	
	# Spawn centered horizontally at bottom of screen
	enemy.position = Vector2(VIEWPORT_WIDTH / 2, VIEWPORT_HEIGHT + 50)
	enemy.enemy_type = enemy_type
	enemy.connect("enemy_destroyed", Callable(self, "_on_enemy_destroyed"))
	
	add_child(enemy)
	current_enemy = enemy
	
	# Decrease spawn interval for next enemy
	spawn_interval = max(min_spawn_interval, spawn_interval - spawn_decrease_rate)

func _on_enemy_destroyed():
	current_enemy = null

func check_collision_with_enemy(enemy):
	if game_over:
		return
	
	var distance = player.position.distance_to(enemy.position)
	print_debug(distance)
	# Conservative collision threshold for large enemies
	# Player radius (25) + enemy radius (varies by shape: ~459 for most shapes)
	if distance < 585:
		# Check if player's ability wins against this enemy
		if does_player_win(enemy.enemy_type):
			# Player wins - remove enemy, player survives
			enemy.emit_signal("enemy_destroyed")
			enemy.queue_free()
		else:
			# Player loses - game over
			trigger_game_over()


func get_enemy_color(enemy_type: int) -> Color:
	# Return the color for the given enemy type (enemies use same colors as abilities)
	if enemy_type in ability_config:
		return ability_config[enemy_type]["color"]
	return Color.WHITE

#-------------------------------------------------------------------------------
# Player
#-------------------------------------------------------------------------------

func init_player():
	player.position = Vector2(VIEWPORT_WIDTH / 2, VIEWPORT_HEIGHT / 2)
	update_player_color()

func update_ability_display():
	var ability_name = ability_config[current_ability]["name"]
	ability_label.text = "Ability %d: %s" % [current_ability, ability_name]

func update_player_color():
	player.current_color = ability_config[current_ability]["color"]
	player.queue_redraw()

func does_player_win(enemy_type: int) -> bool:
	# Check if current ability wins against the given enemy type
	return enemy_type in ability_config[current_ability]["wins_against"]


func _draw():
	# Draw scrolling background pattern
	var tile_size = 100
	var y_offset = int(scroll_offset) % tile_size
	
	for y in range(-1, int(VIEWPORT_HEIGHT / tile_size) + 2):
		for x in range(int(VIEWPORT_WIDTH / tile_size) + 1):
			var pos_y = y * tile_size - y_offset
			var pos_x = x * tile_size
			var color = Color(0.1, 0.1, 0.15, 1.0)
			if (x + y) % 2 == 0:
				color = Color(0.15, 0.15, 0.2, 1.0)
			draw_rect(Rect2(pos_x, pos_y, tile_size - 2, tile_size - 2), color)
