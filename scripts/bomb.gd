extends Area2D

# Bomb configuration
const MAX_RADIUS = 350.0  # Maximum radius the bomb grows to
const GROWTH_SPEED = 700.0  # Pixels per second growth rate
const ENEMY_SHRINK_AMOUNT = 250  # Amount to shrink enemy size (passed to enemy.shrink())

var current_radius = 0.0
var enemies_hit = []  # Track which enemies have already been hit

func _ready():
	area_entered.connect(_on_area_entered)

func _process(delta):
	# Grow the bomb
	current_radius += GROWTH_SPEED * delta
	
	# Check if we've reached max radius
	if current_radius >= MAX_RADIUS:
		queue_free()  # Remove the bomb
		return
	
	# Update collision shape
	if $CollisionShape2D and $CollisionShape2D.shape:
		$CollisionShape2D.shape.radius = current_radius
	
	# Trigger redraw for visual update
	queue_redraw()

func _on_area_entered(area):
	if area.is_in_group("enemy") and area not in enemies_hit:
		enemies_hit.append(area)
		# Shrink the enemy
		if area.has_method("shrink"):
			area.shrink(ENEMY_SHRINK_AMOUNT)
			# Show damage text
			if get_parent().has_method("show_damage_text"):
				get_parent().show_damage_text(area.position, ENEMY_SHRINK_AMOUNT)

func _draw():
	# Draw expanding circle with semi-transparent blue color
	var color = Color(0.0, 0.0, 1.0, 0.3)  # Blue with transparency
	draw_circle(Vector2.ZERO, current_radius, color)
	# Draw outline
	if current_radius > 1.0:
		draw_arc(Vector2.ZERO, current_radius, 0, TAU, 32, Color(0.3, 0.3, 1.0, 0.8), 2.0)
