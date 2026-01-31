extends Node2D

# Configuration
const CIRCLE_RADIUS = 40.0
const CIRCLE_SPACING = 120.0
const Y_POSITION = 1820.0  # Near bottom of viewport (1920 - 100)
const VIEWPORT_WIDTH = 1080
const PULSE_SPEED = 0.005  # Animation speed for pulsing effect
const PULSE_INTENSITY = 0.2  # Scale factor for pulse animation

# References to game controller (parent node)
var parent_game_controller = null
var last_ability = -1
var last_enemy = null

func _ready():
	# Get reference to game controller (parent node)
	parent_game_controller = get_parent()

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
	if current_enemy != null and is_instance_valid(current_enemy):
		current_enemy_type = current_enemy.enemy_type
	
	# Draw each ability circle
	for i in range(1, 6):
		var x_pos = start_x + (i - 1) * CIRCLE_SPACING
		var circle_pos = Vector2(x_pos, Y_POSITION)
		
		# Get ability color
		var ability_color = parent_game_controller.ability_config[i]["color"]
		
		# Determine if this ability is selected or wins against current enemy
		var is_selected = (i == current_ability)
		var wins_against_enemy = false
		
		if current_enemy_type > 0:
			wins_against_enemy = current_enemy_type in parent_game_controller.ability_config[i]["wins_against"]
		
		# Draw the circle
		if is_selected:
			# Selected ability: draw larger with bright outline
			draw_circle(circle_pos, CIRCLE_RADIUS + 8, Color.WHITE)
			draw_circle(circle_pos, CIRCLE_RADIUS + 4, ability_color.lightened(0.3))
			draw_circle(circle_pos, CIRCLE_RADIUS, ability_color)
		elif wins_against_enemy:
			# Winning ability: draw with pulsing glow effect
			var pulse_scale = 1.0 + sin(Time.get_ticks_msec() * PULSE_SPEED) * PULSE_INTENSITY
			draw_circle(circle_pos, CIRCLE_RADIUS * pulse_scale, ability_color.lightened(0.5))
			draw_circle(circle_pos, CIRCLE_RADIUS, ability_color)
			# Add extra bright outline to make it clear
			draw_arc(circle_pos, CIRCLE_RADIUS + 6, 0, TAU, 32, Color.WHITE, 3.0)
		else:
			# Normal ability: draw with dimmed colors
			draw_circle(circle_pos, CIRCLE_RADIUS, ability_color.darkened(0.4))
			draw_circle(circle_pos, CIRCLE_RADIUS - 2, ability_color.darkened(0.6))
		
		# Note: Ability numbers are conveyed through position and color
		# Text drawing is omitted to keep the UI minimal and avoid font dependencies

func _process(_delta):
	if parent_game_controller == null:
		return
	
	# Check if state has changed (ability switch or enemy spawn/destroy)
	var current_ability = parent_game_controller.current_ability
	var current_enemy = parent_game_controller.current_enemy
	
	if current_ability != last_ability or current_enemy != last_enemy:
		last_ability = current_ability
		last_enemy = current_enemy
		queue_redraw()
	# Also redraw continuously when enemy is present for pulsing animation
	elif current_enemy != null:
		queue_redraw()
