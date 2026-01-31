extends CharacterBody2D

const SPEED = 200.0
const VIEWPORT_WIDTH = 1080
const RADIUS = 125

# Current player color (updated by game controller based on ability)
var current_color = Color(0.4, 0.9, 0.4, 1.0)

func _ready():
	queue_redraw()

func _physics_process(delta):
	# Get input direction
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Keep player within bounds
	position.x = clamp(position.x, RADIUS + 10, VIEWPORT_WIDTH - (RADIUS + 10))
	
	move_and_slide()

func _draw():
	# Draw player as a circle with current ability color
	draw_circle(Vector2.ZERO, RADIUS, current_color.darkened(0.3))
	draw_circle(Vector2.ZERO, RADIUS, current_color)
