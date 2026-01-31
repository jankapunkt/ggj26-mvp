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
var max_spawn_interval = 5.0  # Maximum 5 seconds
var spawn_decrease_rate = 0.1  # Decrease by 0.1 seconds each spawn
var spawn_interval_variation = 1.0  # Random variation range (+/- seconds)

# Drag force configuration
const MIN_DRAG_DISTANCE = 0.1  # Minimum distance threshold to prevent division by zero when normalizing
var drag_strength = 800.0 # Apply a strong drag force (x units/sec)

# Game state
var game_over = false
var scroll_offset = 0.0
var enemies = []  # Array to hold multiple enemies
var time_since_last_spawn = 0.0
var current_ability = 4 # Default ability is 4 (White)

# Ability system configuration
# Maps ability number to: [color, [enemies it wins against]]
var ability_config = {
	1: {"color": Color(1.0, 0.0, 0.0, 0.7), "name": "Red", "wins_against": [1], "shrink": 25},
	2: {"color": Color(0.0, 1.0, 0.0, 0.7), "name": "Green", "wins_against": [2], "shrink": 25},
	3: {"color": Color(0.0, 0.0, 1.0, 0.7), "name": "Blue", "wins_against": [3], "shrink": 25 },
	4: {"color": Color(1.0, 1.0, 1.0, 0.7), "name": "White", "wins_against": [1,2, 3], "shrink": 10}
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
	
	# Check collision with all enemies
	for enemy in enemies:
		if is_instance_valid(enemy):
			check_collision_with_enemy(enemy)
	
	# Handle enemy spawning
	time_since_last_spawn += delta
	if time_since_last_spawn >= spawn_interval:
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

func check_collision_with_chaser(chaser):
	if game_over:
		return
	var distance = player.position.distance_to(chaser.position)
	# Conservative collision threshold for large enemies
	# Player radius (125) + chaser radius (~459) = (rounded up) 585
	if distance <= 585:
		# Player loses - game over
		trigger_game_over()
	
#-------------------------------------------------------------------------------
# Enemies
#-------------------------------------------------------------------------------

func spawn_enemy():
	# Random enemy type (1-3)
	var enemy_type = randi() % 3 + 1
	var enemy = preload("res://scenes/enemy.tscn").instantiate()
	
	# Randomize initial enemy size to determine spawn constraints
	var initial_size = randi_range(100, enemy.ENEMY_SIZE)
	var enemy_radius = initial_size / 2
	
	# Calculate safe horizontal spawn range to ensure enemy fits within bounds
	# Account for enemy radius on both sides
	var min_x = enemy_radius
	var max_x = VIEWPORT_WIDTH - enemy_radius
	
	# Random horizontal position within safe bounds
	var spawn_x = randf_range(min_x, max_x)
	
	# Spawn at bottom of screen, outside visible area
	enemy.position = Vector2(spawn_x, VIEWPORT_HEIGHT + enemy_radius + 50)
	enemy.enemy_type = enemy_type
	enemy.current_size = initial_size  # Set size before ready() is called
	enemy.size_initialized_by_spawner = true  # Flag that size was set externally
	enemy.connect("enemy_destroyed", Callable(self, "_on_enemy_destroyed").bind(enemy))
	
	add_child(enemy)
	enemies.append(enemy)
	
	# Calculate next spawn interval with variation
	var base_interval = max(min_spawn_interval, spawn_interval - spawn_decrease_rate)
	var variation = randf_range(-spawn_interval_variation, spawn_interval_variation)
	spawn_interval = clamp(base_interval + variation, min_spawn_interval, max_spawn_interval)

func _on_enemy_destroyed(enemy):
	# Remove enemy from the array
	if enemy in enemies:
		enemies.erase(enemy)

func check_collision_with_enemy(enemy):
	if game_over:
		return
	
	var distance = player.position.distance_to(enemy.position)
	# Conservative collision threshold for large enemies
	# Player radius (125) + enemy radius (current_size / 2) + small buffer
	var collision_threshold = 125 + (enemy.current_size / 2) + 10
	if distance <= collision_threshold:
		# Check if player's ability wins against this enemy
		if does_player_win(enemy.enemy_type):
			# Player wins - remove enemy, player survives
			enemy.emit_signal("enemy_destroyed")
			enemy.queue_free()
		else:
			# Player doesn't win - apply drag force towards chaser
			# Calculate direction from player to chaser (upward, toward top of screen)
			var direction_vector = chaser.position - player.position
			# Only apply drag if there's a meaningful distance (avoid division by zero)
			if direction_vector.length() > MIN_DRAG_DISTANCE:
				var drag_direction = direction_vector.normalized()
				player.drag_force = drag_direction * drag_strength


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
	# return enemy_type in ability_config[current_ability]["wins_against"]
	return false

func _on_bullet_hit_enemy(enemy):
	if enemy and is_instance_valid(enemy):
		var enemy_type = enemy.enemy_type 
		if enemy_type in ability_config[current_ability]["wins_against"]:
			enemy.shrink(ability_config[current_ability]["shrink"])

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
