extends Area2D

signal enemy_destroyed

var enemy_type = 1
var move_speed = 400.0

# Enemy size configuration - 85% of screen width (1080 * 0.85 = 918)
const ENEMY_SIZE = 918.0
const ENEMY_ALPHA = 0.6

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	# Move enemy upward (creating illusion of player moving down)
	position.y -= move_speed * delta
	
	# Check if enemy has moved off screen (top)
	if position.y < -100:
		emit_signal("enemy_destroyed")
		queue_free()
	
	queue_redraw()

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Notify game controller of collision
		get_parent().check_collision_with_enemy(self)

func _draw():
	var col
	match enemy_type:
		1:  # Type 1: Triangle
			col = Color(0.904, 0.246, 0.789, ENEMY_ALPHA)
		2:  # Type 2: Square
			col = Color(0.9, 0.4, 0.2, ENEMY_ALPHA)
		3:  # Type 3: Hexagon
			col = Color(0.338, 0.571, 0.924, ENEMY_ALPHA)
		4:	# Type 4:
			col = Color(0.0, 0.667, 0.56, ENEMY_ALPHA)
		5: 	# Type5_
			col = Color(0.55, 0.61, 0.241, ENEMY_ALPHA)
	drawCircle(col)

			
func drawCircle(col):
	var radius = ENEMY_SIZE / 2
	var points = Vector2(0, 0)
	draw_circle(points, radius, col, true)
