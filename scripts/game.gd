extends Node2D

# Game configuration
const VIEWPORT_WIDTH = 1080
const VIEWPORT_HEIGHT = 1920
const PLAYER_Y_POSITION = VIEWPORT_HEIGHT / 3  # Upper third

# Scrolling configuration
const SCROLL_SPEED = 100.0  # Pixels per second

# Enemy spawn configuration
var spawn_interval = 5.0  # Start with 3 seconds
var min_spawn_interval = 0.5  # Minimum 0.5 seconds
var spawn_decrease_rate = 0.1  # Decrease by 0.1 seconds each spawn

# Drag force configuration
const MIN_DRAG_DISTANCE = 0.1  # Minimum distance threshold to prevent division by zero when normalizing
var drag_strength = 800.0 # Apply a strong drag force (x units/sec)

# Game state
var game_over = false
var scroll_offset = 0.0
var enemies = [] # hold current enemies
var current_enemy = null
var time_since_last_spawn = 0.0
var current_ability = 4 # Default ability 4 (white)
var max_enemy_size = 150.0

@onready var ability_switch_sound_effect = [
	preload("res://assets/sounds/mask_switch_africa.wav"),
	preload("res://assets/sounds/mask_switch_japan.wav"),
	preload("res://assets/sounds/mask_switch_mexico.wav")
]
#Background
@onready var bg_a: Sprite2D = $Sprite2D_A
@onready var bg_b: Sprite2D = $Sprite2D_B

const BG_SCROLL_SPEED = 200.0
const BG_HEIGHT = 1920


# Ability system configuration
# Maps ability number to: [color, [enemies it wins against]]
var ability_config = {
	1: {"color": Color(1.0, 0.0, 0.0, 0.1), "name": "Red", "wins_against": [1], "shrink": 35},
	2: {"color": Color(0.0, 1.0, 0.0, 0.1), "name": "Green", "wins_against": [2], "shrink": 35},
	3: {"color": Color(0.0, 0.0, 1.0, 0.1), "name": "Blue", "wins_against": [3], "shrink": 35 },
	4: {"color": Color(1.0, 1.0, 1.0, 0.1), "name": "White", "wins_against": [1,2, 3], "shrink": 10}
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

	update_background(delta)

	# Handle ability switching
	for i in range(1, 6):
		if Input.is_action_just_pressed("ability_%d" % i):
			current_ability = i
			playAbilitySwitchSound()
			update_ability_display()
			update_player_color()
	
	if Input.is_action_just_pressed("ability_left"):
		current_ability = current_ability - 1
		if current_ability < 1:
			current_ability = 4
		update_ability_display()
		update_player_color()
		
	if Input.is_action_just_pressed("ability_right"):
		current_ability = current_ability + 1
		if current_ability > 4:
			current_ability = 1
		update_ability_display()
		update_player_color()
	
	# Update scroll effect
	scroll_offset += SCROLL_SPEED * delta
	queue_redraw()
	
	# Update chaser to follow player
	update_chaser()
	
	# instead of event based collision we do continuous collision
	# to apply drag forces
	for enemy in enemies:
		check_collision_with_enemy(enemy)
	
	# Handle enemy spawning
	time_since_last_spawn += delta
	if time_since_last_spawn >= spawn_interval:
		spawn_enemy()
		time_since_last_spawn = 0.0

func update_background(delta):
	bg_a.position.y -= BG_SCROLL_SPEED * delta
	bg_b.position.y -= BG_SCROLL_SPEED * delta

	# Looping
	if bg_a.position.y <= -BG_HEIGHT * 0.5:
		bg_a.position.y = bg_b.position.y + BG_HEIGHT
	if bg_b.position.y <= -BG_HEIGHT * 0.5:
		bg_b.position.y = bg_a.position.y + BG_HEIGHT


func trigger_game_over():
	game_over = true
	game_over_screen.visible = true
	$GameOverSound.play()
	

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
	print_debug('spawn enemy', enemies.size())
	# Random enemy type (1-5)
	var enemy_type = randi() % 3 + 1
	var enemy = preload("res://scenes/enemy.tscn").instantiate()
	enemy.init(max_enemy_size)
	# Spawn centered horizontally at bottom of screen
	enemy.position = Vector2(VIEWPORT_WIDTH / 2, VIEWPORT_HEIGHT + 50)
	enemy.enemy_type = enemy_type
	enemy.connect("enemy_destroyed", Callable(self, "_on_enemy_destroyed"))
	
	add_child(enemy)
	enemies.append(enemy)
	
	# Decrease spawn interval for next enemy
	spawn_interval = max(min_spawn_interval, spawn_interval - spawn_decrease_rate)

func _on_enemy_destroyed(enemy):
	print_debug("on enemy destroyed", enemy)
	max_enemy_size += 700
	if enemy in enemies:
		enemies.erase(enemy)

func check_collision_with_enemy(enemy):
	if game_over or enemy == null:
		return
	
	var distance = player.position.distance_to(enemy.position)
	# Conservative collision threshold for large enemies
	# Player radius (125) + enemy radius (current_size / 2) + small buffer
	var collision_threshold = 125 + (enemy.current_size / 2) + 10
	if distance <= collision_threshold:
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
	
func playAbilitySwitchSound():
	var ability_name = ability_config[current_ability]["name"]
	if ability_name == "Red":
		$AbilitySwitchSound.stream = ability_switch_sound_effect.get(0)
		$AbilitySwitchSound.play()
	elif ability_name == "Blue":
		$AbilitySwitchSound.stream = ability_switch_sound_effect.get(1)
		$AbilitySwitchSound.play()
	elif ability_name == "Green":
		$AbilitySwitchSound.stream = ability_switch_sound_effect.get(2)
		$AbilitySwitchSound.play()
		
			


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

'func _draw():
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
'
