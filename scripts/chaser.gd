extends Area2D

func _ready():
	z_index = 10 
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _draw():
	# Draw elliptic shape (elongated vertically)
	var ellipse_width = 1080
	var ellipse_height = 50
	var num_points = 32
	
	var points = PackedVector2Array()
	for i in range(num_points):
		var angle = (i / float(num_points)) * TAU
		var x = cos(angle) * ellipse_width
		var y = sin(angle) * ellipse_height
		points.append(Vector2(x, y))
	
	draw_colored_polygon(points, Color(0.8, 0.2, 0.2, 0.7))
	
	# Draw outline
	for i in range(num_points):
		var next_i = (i + 1) % num_points
		draw_line(points[i], points[next_i], Color(1.0, 0.3, 0.3, 1.0), 2.0)

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Notify game controller of collision with chaser
		get_parent().check_collision_with_chaser(self)
