extends Area2D

signal enemy_destroyed

var enemy_type = 1
var move_speed = 120.0

# Enemy size configuration - 85% of screen width (1080 * 0.85 = 918)
const ENEMY_SIZE = 918.0

func _ready():
	pass

func _process(delta):
	# Move enemy upward (creating illusion of player moving down)
	position.y -= move_speed * delta
	
	# Move enemy towards player's horizontal position
	var player = get_parent().get_node_or_null("Player")
	if player:
		var direction_to_player = sign(player.position.x - position.x)
		var horizontal_speed = move_speed * 0.5  # Move at 50% of vertical speed horizontally
		position.x += direction_to_player * horizontal_speed * delta
	
	# Check if enemy has moved off screen (top)
	if position.y < -100:
		emit_signal("enemy_destroyed")
		queue_free()
	
	queue_redraw()

func _draw():
	var color = get_enemy_color()
	# All enemies are now circles with different colors
	draw_circle_enemy(color)

func get_enemy_color() -> Color:
	# Get color from parent game controller
	if get_parent().has_method("get_enemy_color"):
		return get_parent().get_enemy_color(enemy_type)
	# Fallback colors
	match enemy_type:
		1: return Color(0.58, 0.0, 0.83)   # Violet
		2: return Color(1.0, 1.0, 0.0)     # Yellow
		3: return Color(1.0, 0.0, 0.0)     # Red
		4: return Color(0.0, 1.0, 0.0)     # Green
		5: return Color(0.0, 0.0, 1.0)     # Blue
		_: return Color.WHITE

func draw_circle_enemy(base_color: Color):
	var radius = ENEMY_SIZE / 2
	draw_circle(Vector2.ZERO, radius, base_color)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, base_color.lightened(0.2), 2.0)
