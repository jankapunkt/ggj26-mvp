extends Node2D

# Game configuration
const VIEWPORT_WIDTH = 1080
const VIEWPORT_HEIGHT = 1920
const PLAYER_Y_POSITION = VIEWPORT_HEIGHT / 3  # Upper third

@onready var japan: Sprite2D = $Player/japan
@onready var mexican: Sprite2D = $Player/mexican
@onready var bob: Sprite2D = $Player/bob
@onready var african: Sprite2D = $Player/african
@onready var jason: Sprite2D = $Player/jason


# Scrolling configuration
const SCROLL_SPEED = 10.0  # Pixels per second

# Enemy spawn configuration
var spawn_interval = 2.0  # Start with 3 seconds
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
var current_score = 0  # Score tracking

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
	1: {"color": Color(1.0, 0.0, 0.0, 0.1), "name": "Red", "wins_against": [1, 2, 3], "shrink": 12},
	2: {"color": Color(0.0, 1.0, 0.0, 0.1), "name": "Green", "wins_against": [1, 2, 3], "shrink": 75 },
	3: {"color": Color(0.0, 0.0, 1.0, 0.1), "name": "Blue", "wins_against": [1, 2, 3], "shrink": 35 },
	4: {"color": Color(1.0, 1.0, 1.0, 0.1), "name": "White", "wins_against": [1,2, 3], "shrink": 10}
}

# Gauge system configuration
const MAX_GAUGE = 100.0
const GAUGE_REFILL_RATE = 300.0  # Units per second when White ability is active
var do_refill_gauge = false

# Gauge tracking for abilities 1-3 (Red, Green, Blue)
var ability_gauges = {
	1: 0,  # RedS
	2: 0,  # Green
	3: 0   # Blue
}

const GAUGE_DECREASE = {
	1: 1,
	2: 5,
	3: 10
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
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_screen.visible = false
	update_ability_display()
	init_player()
	set_chaser_position()
	japan.visible = false
	jason.visible = false
	african.visible = false
	mexican.visible = false
	bob.visible = true

func toggle_pause():
	if game_over: return
	
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	
var mat: ShaderMaterial
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()
		
	if get_tree().paused: 
		return
	if game_over:
		if Input.is_action_just_pressed("ui_accept"):
			restart_game()
		return
	update_background(delta)


	# Handle ability switching
	for i in range(1, 5):
		if Input.is_action_just_pressed("ability_%d" % i):
			print_debug('ability pressed', i)
			current_ability = i
			playAbilitySwitchSound()
			update_ability_display()
			update_player_color()
	
	if Input.is_action_just_pressed("ability_left"):
		current_ability = current_ability - 1
		if current_ability < 1:
			current_ability = 4
		playAbilitySwitchSound()
		update_ability_display()
		update_player_color()
		
	if Input.is_action_just_pressed("ability_right"):
		current_ability = current_ability + 1
		if current_ability > 4:
			current_ability = 1
		playAbilitySwitchSound()
		update_ability_display()
		update_player_color()
	
	# update player
	player.current_type = current_ability
	
	# Update scroll effect
	scroll_offset += SCROLL_SPEED * delta
	queue_redraw()
	
	# Update chaser to follow player
	update_chaser()
	
	# instead of event based collision we do continuous collision
	# to apply drag forces
	for enemy in enemies:
		check_player_collision_with(enemy)
		check_chaser_collision_with(enemy)
	
	# Handle gauge refill when White ability (4) is active
	if do_refill_gauge:
		refill_gauges(current_ability, delta)
	do_refill_gauge = false
	
	# Handle enemy spawning
	time_since_last_spawn += delta
	if time_since_last_spawn >= spawn_interval:
		spawn_enemy()
		time_since_last_spawn = 0.0

func update_background(delta):
	if bg_a == null or bg_b == null: 
		push_error("Background sprites not found")
		return	

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
	$EatSound.play()
	$DeathSound.play()
	
	

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
	
	enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
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
	max_enemy_size += 5
	# Increase score by 5 when enemy is destroyed
	current_score += 5
	if enemy in enemies:
		enemies.erase(enemy)
 
func check_player_collision_with(enemy):
	if game_over or enemy == null:
		return
	
	# player collision
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

func check_chaser_collision_with(enemy):
	if game_over or enemy == null:
		return
	# chaser collision
	var distance = chaser.position.distance_to(enemy.position)
	# Conservative collision threshold for large enemies
	# Player radius (125) + enemy radius (current_size / 2) + small buffer
	var collision_threshold = 125 + (enemy.current_size / 2) + 10
	if distance <= collision_threshold:
		# if chaser "eats" an enemy, it grows and the enemy dies
		enemy.shrink(10000)
		chaser.position.y += 100

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
		japan.visible = false
		african.visible = true
		mexican.visible = false
		bob.visible = true
		$AbilitySwitchSound.play()
	elif ability_name == "Blue":
		$AbilitySwitchSound.stream = ability_switch_sound_effect.get(1)
		$AbilitySwitchSound.play()
		japan.visible = true
		african.visible = false
		mexican.visible = false
		bob.visible = true
	elif ability_name == "Green":
		$AbilitySwitchSound.stream = ability_switch_sound_effect.get(2)
		$AbilitySwitchSound.play()
		japan.visible = false
		african.visible = false
		mexican.visible = true
		bob.visible = true
	else: 
		japan.visible = false
		african.visible = false
		mexican.visible = false
		bob.visible = true
		
		
			


func update_player_color():
	player.current_color = ability_config[current_ability]["color"]
	player.queue_redraw()

func does_player_win(_enemy_type: int) -> bool:
	# Check if current ability wins against the given enemy type
	# return enemy_type in ability_config[current_ability]["wins_against"]
	return false

func _on_bullet_hit_enemy(enemy):
	if enemy and is_instance_valid(enemy):
		var enemy_type = enemy.enemy_type
		if enemy_type in ability_config[current_ability]["wins_against"]:
			enemy.shrink(ability_config[current_ability]["shrink"])
			do_refill_gauge = true
			# Increase score by 1 when bullet hits an enemy
			current_score += 1

#-------------------------------------------------------------------------------
# Gauge System
#-------------------------------------------------------------------------------

func refill_gauges(current, delta):
	"""Refill all ability gauges when White ability is active"""
	
	for ability_id in ability_gauges.keys():
		if ability_id != current:
			var refill_value = GAUGE_REFILL_RATE / ability_id
			ability_gauges[ability_id] = min(ability_gauges[ability_id] + refill_value * delta, MAX_GAUGE)

func can_shoot() -> bool:
	"""Check if the current ability has enough gauge to shoot"""
	# White ability (4) has no gauge limitation
	if current_ability == 4:
		return true
	# Abilities 1-3 require sufficient gauge
	if current_ability in ability_gauges:
		return ability_gauges[current_ability] >= GAUGE_DECREASE[current_ability]
	return false

func consume_gauge():
	"""Decrease gauge for current ability after shooting"""
	if current_ability in ability_gauges:
		ability_gauges[current_ability] = max(0, ability_gauges[current_ability] - GAUGE_DECREASE[current_ability])

func get_gauge_percentage(ability_id: int) -> float:
	"""Get the gauge level as a percentage (0.0 to 1.0)"""
	if ability_id in ability_gauges:
		return ability_gauges[ability_id] / MAX_GAUGE
	return 1.0  # White ability always returns full

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
