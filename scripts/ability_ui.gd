extends Node2D

# Configuration
const CIRCLE_RADIUS = 40.0
const CIRCLE_SPACING = 120.0
const Y_POSITION = 1820.0  # Near bottom of viewport (1920 - 100)
const VIEWPORT_WIDTH = 1350
const PULSE_SPEED = 0.005  # Animation speed for pulsing effect
const PULSE_INTENSITY = 0.2  # Scale factor for pulse animation

@onready var ability_icons := {
	1: $african,
	2: $mexican,
	3: $japan
}

# References to game controller (grandparent node through CanvasLayer)
var parent_game_controller = null
var last_ability = -1
var last_enemy = null
var last_gauge_values = {}  # Track gauge values to detect changes

func _ready():
	# Get reference to game controller (grandparent node: CanvasLayer -> Game)
	parent_game_controller = get_parent().get_parent()

func _draw():
	if parent_game_controller == null:
		return
	
	# Calculate center position for all 5 abilities
	var total_width = 4 * CIRCLE_SPACING  # 4 gaps between 5 circles
	var start_x = (VIEWPORT_WIDTH - total_width) / 2
	
	# Get current ability and current enemy
	var current_ability = parent_game_controller.current_ability
	var current_enemy = parent_game_controller.current_enemy
	var current_enemy_type = 0
	if current_enemy != null and is_instance_valid(current_enemy) and "enemy_type" in current_enemy:
		current_enemy_type = current_enemy.enemy_type
	
	# Draw each ability circle
	for i in range(1, 4):
		var x_pos = start_x + (i - 1) * CIRCLE_SPACING
		var circle_pos = Vector2(x_pos, Y_POSITION)
		
		var icon: Sprite2D = ability_icons[i]
		icon.position = circle_pos
		icon.z_index = 10 
		var target_size = CIRCLE_RADIUS * 1.4
		var tex_size = icon.texture.get_size().x
		icon.scale = Vector2.ONE * (target_size / tex_size)

		
		# Get ability color
		var ability_color = parent_game_controller.ability_config[i]["color"]
		
		# Get gauge percentage for this ability
		var gauge_percentage = 1.0
		if parent_game_controller.has_method("get_gauge_percentage"):
			gauge_percentage = parent_game_controller.get_gauge_percentage(i)
		
		# Determine if this ability is selected or wins against current enemy
		var is_selected = (i == current_ability)
		var alpha = 0.9 if is_selected else 0.25
		
		
		# Draw gauge indicator as a filled arc around the circle
		if gauge_percentage < 0.95:  # Only show gauge indicator when meaningfully depleted
			# Draw empty gauge background (red)
			draw_arc(circle_pos, CIRCLE_RADIUS + 4, 0, TAU, 32, Color(0.5, 0.0, 0.0, 0.7), 6.0)
			
			# Draw filled gauge (based on percentage)
			if gauge_percentage > 0:
				var gauge_angle = TAU * gauge_percentage
				var gauge_color = Color(0.0, 1.0, 0.0, alpha) if gauge_percentage > 0.3 else Color(1.0, 0.5, 0.0, alpha)
				draw_arc(circle_pos, CIRCLE_RADIUS + 4, 0, gauge_angle, 32, gauge_color, 6.0)
		else:
			# draw full gauge
			draw_arc(circle_pos, CIRCLE_RADIUS + 4, 0,  TAU * gauge_percentage, 32, Color(0.0, 1.0, 0.0, alpha), 6.0)
		
		# Note: Ability numbers are conveyed through position and color
		# Text drawing is omitted to keep the UI minimal and avoid font dependencies

func _process(_delta):
	if parent_game_controller == null:
		return
	
	# Check if state has changed (ability switch, enemy spawn/destroy, or gauge change)
	var current_ability = parent_game_controller.current_ability
	var current_enemy = parent_game_controller.current_enemy
	var gauges_changed = false
	
	# Check if gauges have changed
	if parent_game_controller.has_method("get_gauge_percentage"):
		for i in range(1, 4):
			var current_gauge = parent_game_controller.get_gauge_percentage(i)
			if not last_gauge_values.has(i) or abs(last_gauge_values[i] - current_gauge) > 0.01:
				last_gauge_values[i] = current_gauge
				gauges_changed = true
	
	if current_ability != last_ability or current_enemy != last_enemy or gauges_changed:
		last_ability = current_ability
		last_enemy = current_enemy
		queue_redraw()
	# Also redraw when enemy is present and there are winning abilities to animate
	elif current_enemy != null and is_instance_valid(current_enemy):
		# Check if any ability wins against current enemy (has pulsing animation)
		var enemy_type = current_enemy.enemy_type if "enemy_type" in current_enemy else 0
		if enemy_type > 0:
			for i in range(1, 4):
				if i != current_ability and enemy_type in parent_game_controller.ability_config[i]["wins_against"]:
					queue_redraw()
					break
