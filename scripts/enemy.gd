extends Area2D

signal enemy_destroyed

var enemy_type = 1
var move_speed = 120.0
var size_initialized_by_spawner = false  # Track if size was set externally

# Enemy size configuration - 85% of screen width (1080 * 0.85 = 918)
const ENEMY_SIZE = 918.0

var current_size = ENEMY_SIZE

@onready var collision_shape = $CollisionShape2D

func _ready():
	# Only set random size if not already set by spawner
	if not size_initialized_by_spawner:
		current_size = randi_range(100, ENEMY_SIZE)
	move_speed = remap(current_size, 100, ENEMY_SIZE, 300, 120)
	add_to_group("enemy")

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

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Notify game controller of collision
		get_parent().check_collision_with_enemy(self)

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
		1: return Color(1.0, 0.0, 0.0, 0.7)     # Red
		2: return Color(0.0, 1.0, 0.0, 0.7)     # Green
		3: return Color(0.0, 0.0, 1.0, 0.7)     # Blue
		_: return Color.WHITE

func draw_circle_enemy(base_color: Color):
	var radius = current_size / 2
	draw_circle(Vector2.ZERO, radius, base_color)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, base_color.lightened(0.2), 2.0)

func shrink(rate):
	current_size -= rate
	if current_size <= 0:
		emit_signal("enemy_destroyed")
		queue_free()
	else:
		# Update collision shape radius
		if collision_shape and collision_shape.shape:
			collision_shape.shape.radius = current_size / 2
	queue_redraw()
