extends Node2D

# Game configuration
const VIEWPORT_WIDTH = 1080
const VIEWPORT_HEIGHT = 1920
const PLAYER_Y_POSITION = VIEWPORT_HEIGHT / 3  # Upper third

# Scrolling configuration
const SCROLL_SPEED = 400.0  # Pixels per second

# Enemy spawn configuration
var spawn_interval = 2.0  # Start with 3 seconds
var min_spawn_interval = 0.5  # Minimum 0.5 seconds
var spawn_decrease_rate = 0.1  # Decrease by 0.1 seconds each spawn

# Game state
var game_over = false
var scroll_offset = 0.0
var current_enemy = null
var time_since_last_spawn = 0.0
var current_ability = 1  # Default ability 1

# Node references
@onready var player = $Player
@onready var chaser = $Chaser
@onready var game_over_screen = $CanvasLayer/GameOverScreen
@onready var ability_label = $CanvasLayer/AbilityLabel

func _ready():
	game_over_screen.visible = false
	update_ability_display()

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

func update_chaser():
	# Keep chaser static above player (fixed offset, not following)
	chaser.position = Vector2(player.position.x, player.position.y - 100)
	chaser.queue_redraw()

func spawn_enemy():
	# Random enemy type (1-3)
	var enemy_type = randi() % 3 + 1
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

	# Conservative collision threshold for large enemies
	# Player radius (25) + minimum enemy radius (~459 for hexagon/triangle)
	if distance <= 585:
		trigger_game_over()

func trigger_game_over():
	game_over = true
	game_over_screen.visible = true

func restart_game():
	get_tree().reload_current_scene()

func update_ability_display():
	ability_label.text = "Ability: %d" % current_ability

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
