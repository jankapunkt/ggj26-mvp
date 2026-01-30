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
	var color = get_enemy_color()
	match enemy_type:
		1:  # Type 1: Triangle (Violet)
			draw_triangle(color)
		2:  # Type 2: Square (Yellow)
			draw_square(color)
		3:  # Type 3: Hexagon (Red)
			draw_hexagon(color)
		4:  # Type 4: Pentagon (Green)
			draw_pentagon(color)
		5:  # Type 5: Circle (Blue)
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

func draw_triangle(base_color: Color):
	var half_width = ENEMY_SIZE / 2
	var height = ENEMY_SIZE * 0.866  # Equilateral triangle height (sqrt(3)/2)
	var points = PackedVector2Array([
		Vector2(0, -height / 2),
		Vector2(-half_width, height / 2),
		Vector2(half_width, height / 2)
	])
	draw_colored_polygon(points, base_color)
	for i in range(3):
		var next_i = (i + 1) % 3
		draw_line(points[i], points[next_i], base_color.lightened(0.2), 2.0)

func draw_square(base_color: Color):
	var half_size = ENEMY_SIZE / 2
	draw_rect(Rect2(-half_size, -half_size, ENEMY_SIZE, ENEMY_SIZE), base_color)
	draw_rect(Rect2(-half_size, -half_size, ENEMY_SIZE, ENEMY_SIZE), base_color.lightened(0.2), false, 2.0)

func draw_hexagon(base_color: Color):
	var radius = ENEMY_SIZE / 2
	var num_points = 6
	var points = PackedVector2Array()
	
	for i in range(num_points):
		var angle = (i / float(num_points)) * TAU
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector2(x, y))
	
	draw_colored_polygon(points, base_color)
	for i in range(num_points):
		var next_i = (i + 1) % num_points
		draw_line(points[i], points[next_i], base_color.lightened(0.2), 2.0)

func draw_pentagon(base_color: Color):
	var radius = ENEMY_SIZE / 2
	var num_points = 5
	var points = PackedVector2Array()
	
	for i in range(num_points):
		var angle = (i / float(num_points)) * TAU - PI / 2  # Start from top
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector2(x, y))
	
	draw_colored_polygon(points, base_color)
	for i in range(num_points):
		var next_i = (i + 1) % num_points
		draw_line(points[i], points[next_i], base_color.lightened(0.2), 2.0)

func draw_circle_enemy(base_color: Color):
	var radius = ENEMY_SIZE / 2
	draw_circle(Vector2.ZERO, radius, base_color)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, base_color.lightened(0.2), 2.0)
