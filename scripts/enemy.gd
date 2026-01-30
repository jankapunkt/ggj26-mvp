extends Area2D

signal enemy_destroyed

var enemy_type = 1
var move_speed = 120.0

# Enemy size configuration - 85% of screen width (1080 * 0.85 = 918)
const ENEMY_SIZE = 918.0

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
	match enemy_type:
		1:  # Type 1: Triangle
			draw_triangle()
		2:  # Type 2: Square
			draw_square()
		3:  # Type 3: Hexagon
			draw_hexagon()

func draw_triangle():
	var half_width = ENEMY_SIZE / 2
	var height = half_width * 1.732  # Equilateral triangle height
	var points = PackedVector2Array([
		Vector2(0, -height / 2),
		Vector2(-half_width, height / 2),
		Vector2(half_width, height / 2)
	])
	draw_colored_polygon(points, Color(0.9, 0.4, 0.2, 1.0))
	for i in range(3):
		var next_i = (i + 1) % 3
		draw_line(points[i], points[next_i], Color(1.0, 0.5, 0.3, 1.0), 2.0)

func draw_square():
	var half_size = ENEMY_SIZE / 2
	draw_rect(Rect2(-half_size, -half_size, ENEMY_SIZE, ENEMY_SIZE), Color(0.2, 0.4, 0.9, 1.0))
	draw_rect(Rect2(-half_size, -half_size, ENEMY_SIZE, ENEMY_SIZE), Color(0.3, 0.5, 1.0, 1.0), false, 2.0)

func draw_hexagon():
	var radius = ENEMY_SIZE / 2
	var num_points = 6
	var points = PackedVector2Array()
	
	for i in range(num_points):
		var angle = (i / float(num_points)) * TAU
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector2(x, y))
	
	draw_colored_polygon(points, Color(0.7, 0.2, 0.7, 1.0))
	for i in range(num_points):
		var next_i = (i + 1) % num_points
		draw_line(points[i], points[next_i], Color(0.9, 0.4, 0.9, 1.0), 2.0)
